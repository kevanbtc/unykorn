import subprocess
from pathlib import Path
import json
import shutil


def test_compile():
    contracts = list(Path('contracts').glob('*.sol'))
    assert contracts, 'No contracts found'
    build_dir = Path('build')
    if build_dir.exists():
        shutil.rmtree(build_dir)
    build_dir.mkdir()
    compiled_contracts = []
    for contract in contracts:
        cmd = (
            f"npx solcjs --optimize --bin {contract} --include-path node_modules --base-path . -o {build_dir}"
        )
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
        assert result.returncode == 0, (
            f"Compilation failed for {contract}\n{result.stderr}"
        )
        compiled_contracts.append(contract.name)
    print(json.dumps({'contracts': compiled_contracts}))
    shutil.rmtree(build_dir)
