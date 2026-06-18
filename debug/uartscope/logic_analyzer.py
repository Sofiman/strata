import serial

clock_hz=27000000
clock_period_ns=(1000000000//clock_hz)

ser = serial.Serial("/dev/tty.usbserial-20250303171", 115200, timeout=10)

def start_capture():
    ser.write(b'a')

def capture_finished():
    ser.write(b'b')
    state = ser.read()
    return state == 1

def fetch_data():
    ser.write(b'e')
    read_data_width = int.from_bytes(ser.read(), "little")
    print('read_data_width', read_data_width)
    ser.write(b'c')
    data = ser.read(512*read_data_width)
    return [int.from_bytes(data[i:i+read_data_width], "little") for i in range(0,len(data),read_data_width)]

def gen_vcd(data_array, split_layout, filename="output.vcd"):
    splits = [(bits, label, f"!{i}") for i, (bits, label) in enumerate(split_layout)]

    with open(filename, "w") as f:
        # Header
        f.write("$timescale 1ns $end\n")

        # Scopes
        f.write("$scope module top $end\n")

        clock_split_id = "%"
        f.write(f"$var wire 1 {clock_split_id} clock $end") # Clock
        for bits, label, split_id in splits:
            assert split_id != clock_split_id, "Reserved split id for clock"
            if bits > 1:
                f.write(f"$var wire {bits} {split_id} {label} [{bits-1}:0] $end\n")
            else:
                f.write(f"$var wire 1 {split_id} {label} $end\n")
        f.write("$upscope $end\n")
        f.write("$enddefinitions $end\n")

        # Initial value at time 0
        f.write("$dumpvars\n")
        f.write(f"0{clock_split_id}\n")
        for bits, _, split_id in splits:
            f.write(f"b{"x" * bits} {split_id}\n")
        f.write("$end\n")

        # Dump array values at subsequent timestamps
        for i, value in enumerate(data_array):
            timestamp = (i + 1) * clock_period_ns
            f.write(f"#{timestamp}\n")
            f.write(f"1{clock_split_id}\n")

            for bits, _, split_id in reversed(splits):
                if bits > 1:
                    mask = (1 << bits) - 1
                    f.write(f"b{value & mask:0{bits}b} {split_id}\n")
                else:
                    f.write(f"{value & 1}{split_id}\n")
                value = value >> bits

            f.write(f"#{timestamp + clock_period_ns//2}\n")
            f.write(f"0{clock_split_id}\n")

def read_finished():
    ser.write(b'd')
    return int.from_bytes(ser.read(1), "little")

def capture_count():
    ser.write(b'e')
    return int.from_bytes(ser.read(2), "little")

def capture(split_layout=None):
    ser.read_all()
    start_capture()
    while True:
        ser.write(b'b')
        state = int.from_bytes(ser.read(), "little")
        if state == 1:
            print('Capture finished')
            if split_layout is not None:
                print('Fetching data...')
                data = fetch_data()
                print('Generating VCD in `output.vcd`...')
                return gen_vcd(data, split_layout)
            break
        elif state != 0:
            print(f"Unexpected output: {state}")
            break
