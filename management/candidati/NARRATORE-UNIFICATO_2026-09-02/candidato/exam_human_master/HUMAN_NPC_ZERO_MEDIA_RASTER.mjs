export const CONTEXT_RELEASE = 'mission-factory-context-media/1';
export const MAX_CONTEXT_BYTES = 4 * 1024 * 1024;

const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
const SHA = /^[0-9a-f]{64}$/;
const STEP_KEY = /^[a-z][a-z0-9_]{1,63}$/;
const MIME = new Set(['image/png', 'image/jpeg', 'image/webp']);
const EXTENSION = {'image/png':'png', 'image/jpeg':'jpg', 'image/webp':'webp'};
const be32 = (b, i) => ((b[i] * 0x1000000) + (b[i + 1] << 16) + (b[i + 2] << 8) + b[i + 3]) >>> 0;
const le24 = (b, i) => b[i] | (b[i + 1] << 8) | (b[i + 2] << 16);
const le16 = (b, i) => b[i] | (b[i + 1] << 8);

export function inspectContextRaster(input, declaredMime) {
  const b = input instanceof Uint8Array ? input : new Uint8Array(input);
  if (!b.length || b.length > MAX_CONTEXT_BYTES) throw Error('MR_CONTEXT_MEDIA_SIZE');
  let mime = null, width = 0, height = 0;
  if (b.length >= 24 && [137,80,78,71,13,10,26,10].every((x, i) => b[i] === x)) {
    mime = 'image/png'; width = be32(b, 16); height = be32(b, 20);
  } else if (b.length >= 12 && b[0] === 0xff && b[1] === 0xd8) {
    mime = 'image/jpeg'; let i = 2;
    while (i + 8 < b.length) {
      if (b[i] !== 0xff) { i++; continue; }
      const marker = b[i + 1]; i += 2;
      if (marker === 0xd8 || marker === 0xd9) continue;
      const length = (b[i] << 8) | b[i + 1];
      if (length < 2 || i + length > b.length) break;
      if ([0xc0,0xc1,0xc2,0xc3,0xc5,0xc6,0xc7,0xc9,0xca,0xcb,0xcd,0xce,0xcf].includes(marker)) { height = (b[i + 3] << 8) | b[i + 4]; width = (b[i + 5] << 8) | b[i + 6]; break; }
      i += length;
    }
  } else if (b.length >= 30 && String.fromCharCode(...b.slice(0,4)) === 'RIFF' && String.fromCharCode(...b.slice(8,12)) === 'WEBP') {
    mime = 'image/webp'; const chunk = String.fromCharCode(...b.slice(12,16));
    if (chunk === 'VP8X') { width = le24(b, 24) + 1; height = le24(b, 27) + 1; }
    else if (chunk === 'VP8 ' && b.length >= 30 && b[23] === 0x9d && b[24] === 0x01 && b[25] === 0x2a) { width = le16(b, 26) & 0x3fff; height = le16(b, 28) & 0x3fff; }
    else if (chunk === 'VP8L' && b.length >= 25 && b[20] === 0x2f) { width = 1 + (((b[22] & 0x3f) << 8) | b[21]); height = 1 + (((b[24] & 0x0f) << 10) | (b[23] << 2) | ((b[22] & 0xc0) >> 6)); }
  }
  if (!mime || mime !== declaredMime || width < 1 || height < 1 || width > 8192 || height > 8192) throw Error('MR_CONTEXT_MEDIA_RASTER_INVALID');
  return {mime, width, height, bytes: b.byteLength};
}

export function contextHeaders(headers) {
  const get = name => headers?.get?.(name) ?? headers?.[name] ?? '';
  const phase_key = get('x-mf-phase-key');
  const out = {
    draft_id: get('x-mf-draft-id'), phase_key,
    request_key: get('x-mf-request-key'), sha256: get('x-mf-sha256'),
    mime: get('content-type')?.split(';')[0], expected_release: get('x-mf-expected-release')
  };
  if (![out.draft_id, out.request_key].every(x => UUID.test(x)) || !SHA.test(out.sha256) || !MIME.has(out.mime) || out.expected_release !== CONTEXT_RELEASE) throw Error('MR_CONTEXT_MEDIA_HEADERS');
  if (!STEP_KEY.test(phase_key || '')) throw Error('MF_CONTEXT_MEDIA_PHASE');
  return out;
}

export function validContextTicket(ticket, expected) {
  const extension = EXTENSION[expected.mime];
  const expectedPath = `mission-factory-context/${expected.draft_id.toLowerCase()}/${expected.sha256}.${extension}`;
  if (ticket?.schema_version !== 'mission-factory-context-media-ticket/1' || ticket.request_key !== expected.request_key || !UUID.test(ticket.media_id || '') || ticket.bucket !== 'location-images' || ticket.object_path !== expectedPath || ticket.phase_key !== expected.phase_key || typeof ticket.registered !== 'boolean') throw Error('MF_CONTEXT_MEDIA_TICKET_RESPONSE');
  if (ticket.registered && !validContextRegistration(ticket.registration, ticket, expected)) throw Error('MF_CONTEXT_MEDIA_REPLAY_INVALID');
  return ticket;
}

export function validContextRegistration(result, ticket, expected) {
  return result?.schema_version === 'mission-factory-context-media-registration/1' && result.request_key === expected.request_key && result.media_id === ticket.media_id && result.bucket === 'location-images' && result.object_path === ticket.object_path && result.sha256 === expected.sha256 && result.mime_type === expected.mime && result.phase_key === expected.phase_key && result.state === 'registered' && Number.isInteger(result.width_px) && Number.isInteger(result.height_px) && result.width_px >= 1 && result.width_px <= 8192 && result.height_px >= 1 && result.height_px <= 8192;
}

export function isMissingContextObject(status, body) {
  return status === 404 || status === 400 && (body?.code === 'NoSuchKey' || body?.error === 'not_found' || Number(body?.statusCode) === 404 || Number(body?.httpStatusCode) === 404);
}
