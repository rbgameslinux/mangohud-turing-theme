
# =============================================================================
# MangoHud CSV integration - reads performance data logged by MangoHud
# https://github.com/flightlessmango/MangoHud
# =============================================================================
# Requires: MangoHud with output_folder and autostart_log configured
# CSV file format (columns): fps,frametime,cpu_load,cpu_power,gpu_load,
#   cpu_temp,gpu_temp,gpu_core_clock,gpu_mem_clock,gpu_vram_used,
#   gpu_power,ram_used,swap_used,process_rss,cpu_mhz,elapsed

_MH_CACHE_TTL = 0.5
_MH_CSV_DIR = os.path.expanduser("~/.config/MangoHud/mangologs")


class _MangoHudCache:
    _last_values: dict = {}
    _last_read: float = 0

    @classmethod
    def _find_latest_csv(cls) -> Path:
        folder = Path(_MH_CSV_DIR)
        if not folder.exists():
            return None
        files = sorted(folder.glob("*.csv"), key=lambda f: f.stat().st_mtime)
        return files[-1] if files else None

    @classmethod
    def _read(cls):
        csv_path = cls._find_latest_csv()
        if not csv_path:
            cls._last_values = {}
            cls._last_read = time.time()
            return

        try:
            with open(str(csv_path), newline="") as f:
                header = None
                for line in f:
                    line = line.strip()
                    if not line:
                        continue
                    if line.startswith("fps,"):
                        header = [col.strip() for col in line.split(",")]
                        break

                if not header:
                    cls._last_values = {}
                    cls._last_read = time.time()
                    return

                last_row = None
                for line in f:
                    line = line.strip()
                    if line:
                        last_row = [col.strip() for col in line.split(",")]

                if not last_row:
                    cls._last_values = {}
                    cls._last_read = time.time()
                    return

                values = {}
                for i, key in enumerate(header):
                    if i < len(last_row):
                        try:
                            values[key] = float(last_row[i])
                        except ValueError:
                            values[key] = math.nan
                    else:
                        values[key] = math.nan
                cls._last_values = values
        except Exception:
            cls._last_values = {}

        cls._last_read = time.time()

    @classmethod
    def get(cls, key: str) -> float:
        now = time.time()
        if now - cls._last_read > _MH_CACHE_TTL:
            cls._read()
        return cls._last_values.get(key, math.nan)

    @classmethod
    def has_data(cls) -> bool:
        now = time.time()
        if now - cls._last_read > _MH_CACHE_TTL:
            cls._read()
        return len(cls._last_values) > 0


class _MangoHudBase(CustomDataSource):
    _field: str = ""
    _unit: str = ""
    last_val: List[float] = None

    def __init__(self):
        self.last_val = [math.nan] * 30
        self.value = math.nan

    def as_numeric(self) -> float:
        self.value = _MangoHudCache.get(self._field)
        if not math.isnan(self.value):
            self.last_val.append(self.value)
            self.last_val.pop(0)
        return self.value

    def as_string(self) -> str:
        if math.isnan(self.value):
            return "---"
        return f'{self.value:>5.1f}{self._unit}'

    def last_values(self) -> List[float]:
        return self.last_val


class MangoHudDistro(CustomDataSource):
    _distro: str = None

    def __init__(self):
        if MangoHudDistro._distro is None:
            try:
                with open("/etc/os-release") as f:
                    for line in f:
                        if line.startswith("PRETTY_NAME="):
                            MangoHudDistro._distro = (
                                line.split("=", 1)[1].strip().strip('"')
                            )
                            break
            except Exception:
                MangoHudDistro._distro = "Linux"
            if MangoHudDistro._distro is None:
                MangoHudDistro._distro = "Linux"
        self.value = MangoHudDistro._distro

    def as_numeric(self) -> float:
        pass

    def as_string(self) -> str:
        return MangoHudDistro._distro or "Linux"

    def last_values(self) -> List[float]:
        pass


class MangoHudFPS(_MangoHudBase):
    _field = "fps"
    _unit = " FPS"
    _max_sane = 240

    def as_numeric(self) -> float:
        self.value = _MangoHudCache.get(self._field)
        if self.value is not None and not math.isnan(self.value) and self.value > self._max_sane:
            self.value = math.nan
        if not math.isnan(self.value):
            self.last_val.append(self.value)
            self.last_val.pop(0)
        return self.value

    def as_string(self) -> str:
        valid = [v for v in self.last_val if not math.isnan(v)]
        if not valid:
            return "---"
        window = valid[-5:]
        avg = sum(window) / len(window)
        return f'{avg:>5.1f}{self._unit}'


class MangoHudFrametime(_MangoHudBase):
    _field = "frametime"
    _unit = "ms"


class MangoHudGpuLoad(_MangoHudBase):
    _field = "gpu_load"
    _unit = "%"


class MangoHudCpuLoad(_MangoHudBase):
    _field = "cpu_load"
    _unit = "%"


class MangoHudGpuTemp(_MangoHudBase):
    _field = "gpu_temp"
    _unit = "C"


class MangoHudCpuTemp(_MangoHudBase):
    _field = "cpu_temp"
    _unit = "C"


class MangoHudGpuPower(_MangoHudBase):
    _field = "gpu_power"
    _unit = "W"


class MangoHudCpuPower(_MangoHudBase):
    _field = "cpu_power"
    _unit = "W"


class MangoHudGpuCoreClock(_MangoHudBase):
    _field = "gpu_core_clock"
    _unit = "MHz"


class MangoHudRamUsed(_MangoHudBase):
    _field = "ram_used"
    _unit = "MB"


class MangoHudVramUsed(_MangoHudBase):
    _field = "gpu_vram_used"
    _unit = "MB"


class MangoHudGpuMemClock(_MangoHudBase):
    _field = "gpu_mem_clock"
    _unit = "MHz"


class MangoHudCpuMhz(_MangoHudBase):
    _field = "cpu_mhz"
    _unit = "MHz"


class MangoHudSwapUsed(_MangoHudBase):
    _field = "swap_used"
    _unit = "MB"


class MangoHudProcessRss(_MangoHudBase):
    _field = "process_rss"
    _unit = "MB"
