import socket
import sys

server = '127.0.0.1'
port = 16834
errored = False

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.settimeout(0.03)
s.connect((server, port))
if len(sys.argv) >= 2:
    if sys.argv[1] == "pause":
        s.send(b"pausegametime\r\n")
    elif sys.argv[1] == "unpause":
        s.send(b"unpausegametime\r\n")
    else:
        print("Invalid argument")
        errored = True
else:
    print("One argument must be given")
    errored =True
s.close()
if not errored:
    exit(0)
else:
    exit(1)
