#!/usr/bin/env python3

import time
import urllib.request

def signal_ready():
    r = urllib.request.urlopen("http://127.0.0.1:8080/enclave/ready")
    if r.getcode() != 200:
        raise Exception("Expected status code %d but got %d" %
                        (requests.status_codes.codes.ok, r.status_code))


def fetch_addr():
    data = "94f12dd02d4de875db83be6fda36084132efed192b630427c6c784b8f5911e85".encode('utf-8')    
    req = urllib.request.Request("http://127.0.0.1:8080/enclave/hash", data=data, method='POST').add_header('Content-Type', 'text/plain')
    
    with urllib.request.urlopen(req) as response:
        response_body = response.read()
    
    print("[py] Added key digest.")
    print(response_body.decode('utf-8'))



if __name__ == "__main__":
    signal_ready()
    print("[py] Signalled to nitriding that we're ready.")

    time.sleep(1)

    fetch_addr()
    print("[py] Made Web request to the outside world.")

    print("[py] Sleeping for 1 hour.")
    time.sleep(3600)
