from pathlib import Path


def load_env(path):
    """Ek paket gerektirmeden .env dosyasını parse eder."""
    env = {}
    try:
        with open(path) as f:
            for line in f:
                line = line.strip()
                if line and not line.startswith('#') and '=' in line:
                    key, _, val = line.partition('=')
                    env[key.strip()] = val.strip()
    except FileNotFoundError:
        pass
    return env


def get_config(env_path=None):
    """desktop/.env dosyasından yapılandırmayı yükler."""
    import os
    if env_path is None:
        env_path = Path(__file__).parent / ".env"
    env = load_env(env_path)
    return {
        "API_URL": env.get("API_URL", os.environ.get("API_URL", "http://localhost:3000")),
        "INSTITUTION_CODE": env.get("INSTITUTION_CODE", os.environ.get("INSTITUTION_CODE", "")),
        "OFFLINE_SECRET": env.get("OFFLINE_SECRET", os.environ.get("OFFLINE_SECRET", "")),
        "INSTITUTION_NAME": env.get("INSTITUTION_NAME", os.environ.get("INSTITUTION_NAME", "")),
        "UNLOCK_DURATION": int(env.get("UNLOCK_DURATION", os.environ.get("UNLOCK_DURATION", "40"))),
    }
