def assemble_to_binary(assembler_code):
    opcode_dict = {'NOR': '00', 'ADD': '01', 'STA': '10', 'JCC': '11'}

    binary_code = ''
    lines = assembler_code.split('\n')

    for line in lines:
        if line.strip() == '':
            continue  # Ignore empty lines
        instruction, operand = map(str.strip, line.split())

        opcode = opcode_dict.get(instruction)
        if opcode is None:
            print(f"Error: Unknown instruction '{instruction}'")
            return None

        try:
            operand_value = int(operand[1:])
            if not (0 <= operand_value <= 63):
                raise ValueError("Operand value must be between 0 and 63")
        except ValueError:
            print(f"Error: Invalid operand '{operand}'")
            return None

        binary_opcode = format(int(opcode, 2), '02b') if opcode else ''
        binary_operand = format(operand_value, '06b')
        binary_code += binary_opcode + binary_operand + '\n'

    return binary_code

# Example usage
assembler_code = """
ADD x6
NOR x7
ADD x8
STA x16
JCC x5
JCC x5
"""
binary_code = assemble_to_binary(assembler_code)

if binary_code is not None:
    with open('output_binary.txt', 'w') as output_file:
        output_file.write(binary_code)

print("Conversion complete. Check 'output_binary.txt' for the binary code.")

def binary_to_int(binary_code):
    lines = binary_code.strip().split('\n')
    int_values = [str(int(line, 2)) for line in lines]
    return '\n'.join(int_values)

# Lecture du fichier 'output_binary.txt'
with open('output_binary.txt', 'r') as binary_file:
    binary_code = binary_file.read()

# Conversion binaire en entier
int_values = binary_to_int(binary_code)

# Écriture dans le fichier 'output_int.txt'
with open('test.txt', 'w') as int_file:
    int_file.write(int_values)

print("Conversion complete. Check 'output_int.txt' for the integer values.")