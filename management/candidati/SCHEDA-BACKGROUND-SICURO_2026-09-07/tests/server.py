from http.server import ThreadingHTTPServer, SimpleHTTPRequestHandler
from pathlib import Path
import json, os
root=Path(__file__).resolve().parents[1]
os.chdir(root)
class Handler(SimpleHTTPRequestHandler):
    def log_message(self,*args): pass
    def do_POST(self):
        if self.path!='/report': self.send_error(404);return
        n=int(self.headers.get('Content-Length','0'))
        if n>20000: self.send_error(413);return
        data=json.loads(self.rfile.read(n))
        (root/'referti/QA.json').write_text(json.dumps(data,indent=2)+'\n')
        self.send_response(204);self.end_headers()
    def do_GET(self):
        if self.path.startswith('/probe'):
            with (root/'referti/UNEXPECTED_NETWORK.txt').open('a') as f: f.write(self.path+'\n')
            self.send_response(204);self.end_headers();return
        super().do_GET()
print('Banco su http://127.0.0.1:8767/tests/harness.html',flush=True)
ThreadingHTTPServer(('127.0.0.1',8767),Handler).serve_forever()
