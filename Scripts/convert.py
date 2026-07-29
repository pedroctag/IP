import re

ARQUIVO_ENTRADA = 'gabarito.txt'
ARQUIVO_SAIDA = '/mnt/c/users/Pedro/Desktop/IP/UVM/tb/esperado.txt'

with open(ARQUIVO_ENTRADA, 'r') as f_in, open(ARQUIVO_SAIDA, 'w') as f_out:
	for linha in f_in:
		if "core" not in linha:
			continue

		match = re.search(r'core\s+\d+:\s+\d+\s+(0x[0-9a-fA-F]+)\s+\((0x[0-9a-fA-F]+)\)\s*(.*)', linha)

		if match:
			pc = match.group(1)
			opcode = match.group(2)
			acao = match.group(3).strip()
			if pc.startswith("0x00001"):
				continue
			if not acao:
				continue
			tokens = acao.split()
			if tokens[0] == 'c1_fflags' and (tokens[1].startswith('0x')):
				print (tokens)
				del tokens[0:2]
				print (tokens)
			if tokens[0] == 'mem':
				destino = tokens[1].replace('0x', '')
				valor = tokens[2].replace('0x', '')
				tipo = "1"
			elif len(tokens) >= 2 and (tokens[0].startswith('x') or tokens[0].startswith('f')):
				try:
					num_registrador = tokens[0].replace('x', '').replace('f', '')
					registrador_decimal = int(num_registrador)
					destino = f"{registrador_decimal:02x}"
					valor = tokens[1].replace('0x', '')
					tipo = "0"
				except ValueError:
					continue
			else:
				continue

			f_out.write(f"{tipo} {destino} {valor}\n")
