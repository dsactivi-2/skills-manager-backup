#!/usr/bin/env python3
# ============================================
# OLLAMA REQUEST SNIFFER / PROXY
# Zeigt den exakten HTTP-Request deiner App
# Nutzung:
#   1. python3 ollama_sniffer.py
#   2. In deiner App: URL von :11434 auf :11435 ändern
#   3. Request in deiner App auslösen
#   4. Hier siehst du den exakten Pfad, Header & Body
# ============================================
import socket
import threading

OLLAMA_HOST = '127.0.0.1'
OLLAMA_PORT = 11434
PROXY_PORT = 11435

def handle_client(client_sock):
    # 1. Vom Client empfangen (deine App)
    request_data = b''
    client_sock.settimeout(3)
    while True:
        try:
            chunk = client_sock.recv(8192)
            if not chunk:
                break
            request_data += chunk
        except socket.timeout:
            break
    
    # 2. Ausgeben
    print("\n" + "="*70)
    print(" GEFANGENER REQUEST (was deine App WIRKLICH sendet):")
    print("="*70)
    try:
        print(request_data.decode('utf-8', errors='replace')[:3000])
    except:
        print(request_data[:3000])
    print("="*70)
    
    # 3. An echten Ollama weiterleiten
    upstream = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    upstream.settimeout(10)
    try:
        upstream.connect((OLLAMA_HOST, OLLAMA_PORT))
        upstream.sendall(request_data)
        
        # Antwort von Ollama zurück an deine App
        while True:
            chunk = upstream.recv(8192)
            if not chunk:
                break
            client_sock.sendall(chunk)
    except Exception as e:
        print(f"FEHLER Weiterleitung: {e}")
        client_sock.sendall(b"HTTP/1.1 502 Bad Gateway\r\n\r\n")
    finally:
        upstream.close()
        client_sock.close()

# Server starten
server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
server.bind(('127.0.0.1', PROXY_PORT))
server.listen(5)

print(f"Proxy läuft: 127.0.0.1:{PROXY_PORT}  ->  Ollama {OLLAMA_HOST}:{OLLAMA_PORT}")
print("Trage in deiner App/Software als Ollama-URL ein:")
print(f"  http://127.0.0.1:{PROXY_PORT}")
print("Führe dann einen Request aus. Du siehst hier exakt den Pfad & Body.\n")
print("Beenden: Ctrl+C\n")

try:
    while True:
        client, addr = server.accept()
        t = threading.Thread(target=handle_client, args=(client,), daemon=True)
        t.start()
except KeyboardInterrupt:
    print("\nProxy beendet.")
    server.close()
