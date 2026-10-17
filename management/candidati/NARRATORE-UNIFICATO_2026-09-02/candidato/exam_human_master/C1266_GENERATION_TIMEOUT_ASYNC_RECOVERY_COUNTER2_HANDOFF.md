C1266 · CONTROVERIFICA2 INDIPENDENTE · SOURCE_ONLY_RED0/0/3

Manifest dfb8fffb8eb43c21d145215d7fc57f65814342640f65c04da26da0dd3e54d217,30/30refs immutati.

- F1 P2 · Readonly room-state await lacks finite timeout while holding journal Web Lock; busy/inFlight can remain forever. Fix: Bound room RPC by10s and remaining observation time, release lock; retry read only.
- F2 P2 · RPC cause erased; HTTP maps Auth/schema and DTO errors to503/409, UI retries all. Room read blanket retryable. Fix: Closed safe failure classes through adapter and readonly endpoints; retry only transport/timeout/explicit transient SQLSTATE.
- F3 P2 · Valid Staff progress.dispatch null does not close pre-send journal; lostACK recovery validates null as work request. Fix: Validate synchronous no-dispatch progress and close reference; server-owned no_work proof for lostACK distinct from unobservable none.

Nessuna scrittura del reviewer, SQL/provider/browser/runtime0. Source grammarPASS distinto da installabilità e Staff NOT_RUN. Aggregata3 nel medesimo mandato; counter2 rosso preservato.
