export const NPC_MEDIA_RELEASE = 'mission-factory-npc-media/1';
export const MAX_NPC_MEDIA_BYTES = 4 * 1024 * 1024;

const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/;
const SHA = /^[0-9a-f]{64}$/;
const MIME = new Set(['image/png','image/jpeg','image/webp']);
const EXT = {'image/png':'png','image/jpeg':'jpg','image/webp':'webp'};

export function npcMediaHeaders(headers) {
  const get = name => headers?.get?.(name) ?? headers?.[name] ?? '';
  const out = {
    template_id: String(get('x-mf-template-id')).toLowerCase(),
    narrative_version_id: String(get('x-mf-narrative-version-id')).toLowerCase(),
    kind: String(get('x-mf-kind')),
    request_key: String(get('x-mf-request-key')).toLowerCase(),
    sha256: String(get('x-mf-sha256')),
    mime: String(get('content-type')).split(';')[0].toLowerCase(),
    expected_release: String(get('x-mf-expected-release'))
  };
  if (!UUID.test(out.template_id) || !UUID.test(out.narrative_version_id) ||
      !UUID.test(out.request_key) || !SHA.test(out.sha256) ||
      !['portrait','marker'].includes(out.kind) || !MIME.has(out.mime) ||
      out.expected_release !== NPC_MEDIA_RELEASE) throw Error('NPC_MEDIA_HEADERS');
  return out;
}

export function validNpcRegistration(result, ticket, meta, width, height) {
  return result?.schema_version === 'npc-media-registration/1' &&
    result.request_key === meta.request_key &&
    result.template_id === meta.template_id &&
    result.narrative_version_id === meta.narrative_version_id &&
    result.kind === meta.kind && result.media_id === ticket.media_id &&
    result.asset_id === ticket.asset_id && result.bucket === 'avatars' &&
    result.object_path === ticket.object_path &&
    result.sha256 === meta.sha256 && result.bytes === ticket.bytes &&
    result.mime_type === meta.mime && result.width_px === width &&
    result.height_px === height && Number.isInteger(result.width_px) &&
    Number.isInteger(result.height_px) && result.width_px >= 1 &&
    result.width_px <= 8192 && result.height_px >= 1 &&
    result.height_px <= 8192 &&
    result.narrative_content_sha256 === ticket.narrative_content_sha256 &&
    result.mechanical_template_id === ticket.mechanical_template_id &&
    result.state === 'registered';
}

export function validNpcTicket(ticket, meta, size) {
  const asset = `npc_${meta.kind}_${meta.request_key.replaceAll('-','')}_${meta.sha256}`;
  const suffix = `/assets/${asset}_v1.${EXT[meta.mime]}`;
  if (ticket?.schema_version !== 'npc-media-ticket/1' ||
      ticket.request_key !== meta.request_key ||
      ticket.template_id !== meta.template_id ||
      ticket.narrative_version_id !== meta.narrative_version_id ||
      ticket.kind !== meta.kind || !UUID.test(ticket.media_id || '') ||
      ticket.asset_id !== asset || ticket.bucket !== 'avatars' ||
      typeof ticket.object_path !== 'string' ||
      !/^ninja-book\/[a-z0-9_]+\/r[1-9][0-9]*\/assets\/[a-z0-9_]+_v1\.(png|jpg|webp)$/.test(ticket.object_path) ||
      !ticket.object_path.endsWith(suffix) ||
      ticket.sha256 !== meta.sha256 || ticket.bytes !== size ||
      ticket.mime_type !== meta.mime ||
      !SHA.test(ticket.narrative_content_sha256 || '') ||
      !(ticket.mechanical_template_id === null || UUID.test(ticket.mechanical_template_id || '')) ||
      !['pending','registered','approved'].includes(ticket.state))
    throw Error('NPC_MEDIA_TICKET_SHAPE');
  if (ticket.state !== 'pending' &&
      !validNpcRegistration(ticket.registration, ticket, meta,
        ticket.registration?.width_px, ticket.registration?.height_px))
    throw Error('NPC_MEDIA_REPLAY_SHAPE');
  return ticket;
}

export function missingNpcObject(status, body) {
  return status === 404 || status === 400 &&
    (body?.code === 'NoSuchKey' || body?.error === 'not_found' ||
      Number(body?.statusCode) === 404 || Number(body?.httpStatusCode) === 404);
}

// Preserve the reserved legacy completion port; other identities must pass the
// ordinary ticket port's authoritative latest-draft/ownership/head checks.
// This dispatch is deterministic and never retries a rejected RPC via another port.
export function npcMediaTicketRpc(meta) {
  const legacy =
    meta.template_id === '82afcf8c-0a2c-447a-b9a5-0cf6a8b067b7' &&
    meta.narrative_version_id === 'daef66b3-3660-443c-af23-6a7b8351e06e' ||
    meta.template_id === '0aaecee9-7e33-4e91-9a95-af1d691f3a40' &&
    meta.narrative_version_id === 'e962b36d-69ba-41ff-9d9f-4b91934cc226';
  return legacy ? 'npc_media_completion_ticket_v2' : 'npc_media_ticket_v1';
}
