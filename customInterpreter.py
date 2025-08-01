import sys
import matlab.engine

if len(sys.argv) == 1:
    startDirectory = None
elif len(sys.argv) == 2:
    startDirectory = sys.argv[1]
else:
    print("Too many arguments.")
    sys.exit()

sharedEngines = matlab.engine.find_matlab()
if len(sharedEngines) == 0:
    print("No shared engines detected. Starting a new instance...")
    choice = 0
else:
    print("0. (create new instance)")
    for i in range(len(sharedEngines)):
        print(f"{i+1}. {sharedEngines[i]}")
    print()
    choice = input("Connect or create a MATLAB instance: ")
    if choice == "":
        choice = "0"
    choice = int(choice)

if choice == 0:
    if startDirectory is None:
        engine = matlab.engine.start_matlab()
    else:
        engine = matlab.engine.start_matlab(f'-sd "{startDirectory}"')
else:
    if startDirectory is not None:
        print("Supplied start directory is ignored.")
    engine = matlab.engine.connect_matlab(sharedEngines[choice-1])

while True:
    print(">> ", end="", flush=True)
    try:
        cmd = input()
    except KeyboardInterrupt:
        print("")
        pass
    except EOFError:
        print()
        print("Exiting")
        sys.exit()
    else:
        try:
            engine.eval(cmd, nargout=0)
        except (matlab.engine.MatlabExecutionError, SyntaxError):
            pass
