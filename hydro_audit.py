import subprocess
import json
from pathlib import Path
import shutil


def ensure_node_dependencies():
    """Install npm packages if the node_modules directory is missing."""
    if not Path("node_modules/.bin/solcjs").exists():
        print("Installing npm dependencies...")
        run_command("npm install")


def run_command(cmd):
    """Run a shell command and return (stdout, stderr, returncode)."""
    result = subprocess.run(cmd, shell=True, text=True, capture_output=True)
    return result.stdout.strip(), result.stderr.strip(), result.returncode


def check_git_repo():
    print("Checking Git repository...")
    if not Path('.git').exists():
        print("No git repository found.")
        return False
    stdout, _, _ = run_command('git remote')
    if 'origin' in stdout:
        print("Fetching latest changes from origin...")
        run_command('git fetch origin')
        run_command('git pull origin main')
    status, _, _ = run_command('git status --short')
    print('Git status:')
    print(status)
    return True


def run_tests():
    print("Running tests with pytest...")
    output, _, _ = run_command('pytest -q')
    print(output)
    return 'failed' not in output.lower()


def audit_smart_contracts():
    print("Auditing smart contracts...")
    contract_paths = list(Path('contracts').glob('*.sol'))
    compiled = []
    build_dir = Path('build')
    if build_dir.exists():
        shutil.rmtree(build_dir)
    build_dir.mkdir()
    for c in contract_paths:
        cmd = (
            f"npx solcjs --optimize --bin {c} --include-path node_modules --base-path . -o {build_dir}"
        )
        _, err, code = run_command(cmd)
        if code == 0:
            compiled.append(c.name)
        else:
            print(f"Failed to compile {c}: {err}")
    shutil.rmtree(build_dir)
    print(f"Compiled contracts: {compiled}")
    return compiled


def audit_api_routes():
    print("Checking API routes...")
    # Placeholder for future API checks


def audit_frontend():
    print("Auditing frontend UI...")
    # Placeholder for frontend checks


def generate_report(compiled_contracts, tests_ok):
    report = {
        "systemStatus": "COMPLETED" if tests_ok else "FAILED",
        "compiledContracts": compiled_contracts,
    }
    print(json.dumps(report, indent=2))


def main():
    check_git_repo()
    ensure_node_dependencies()
    tests_ok = run_tests()
    compiled = audit_smart_contracts()
    audit_api_routes()
    audit_frontend()
    generate_report(compiled, tests_ok)


if __name__ == "__main__":
    main()
