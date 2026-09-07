export const INTERNAL_TOKEN_HEADER='x-mission-narrator-token';
const MIN_TOKEN_LENGTH=32,MAX_TOKEN_LENGTH=512,encoder=new TextEncoder();

function wellFormed(value){
 return typeof value==='string'&&value.length>=MIN_TOKEN_LENGTH&&value.length<=MAX_TOKEN_LENGTH&&value.trim()===value&&!/[\r\n,]/u.test(value);
}

async function constantTimeEqual(left,right){
 const [a,b]=await Promise.all([
  crypto.subtle.digest('SHA-256',encoder.encode(left)),
  crypto.subtle.digest('SHA-256',encoder.encode(right)),
 ]),x=new Uint8Array(a),y=new Uint8Array(b);
 let difference=left.length^right.length;
 for(let i=0;i<x.length;i++)difference|=x[i]^y[i];
 return difference===0;
}

export async function authorizeInternalRequest(headers,expected){
 if(!wellFormed(expected))return {ok:false,status:503,code:'SERVER_AUTH_CONFIG_INVALID'};
 const supplied=headers.get(INTERNAL_TOKEN_HEADER);
 if(!wellFormed(supplied))return {ok:false,status:401,code:'UNAUTHORIZED'};
 if(!(await constantTimeEqual(supplied,expected)))return {ok:false,status:401,code:'UNAUTHORIZED'};
 return {ok:true,status:200,code:'AUTHORIZED'};
}

