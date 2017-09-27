import platform
import distro
import subprocess
from urllib.request import urlopen
from urllib.error import URLError
from subprocess import check_output
from dateutil.relativedelta import relativedelta

def sanitize(data):
    cleaned_data = data.strip().decode("utf-8")
    return cleaned_data


def get_public_ip():
    try:
        with urlopen('http://checkip.amazonaws.com') as url:
            public_ip = sanitize(url.read())
            return public_ip
    except URLError as e:
        public_ip = 'e'
        return public_ip
    except KeyboardInterrupt:
        pass


def get_os_info(cpu_model=None, mem_total=None, mem_avail=None, swap_total=None, swap_free=None):

    with open('/proc/uptime', 'r') as f:
        uptime_seconds = round(float(f.readline().split()[0]))
    intervals = ['years', 'months', 'days', 'hours', 'minutes', 'seconds']
    relative_uptime_seconds = relativedelta(seconds=uptime_seconds)
    uptime = ' '.join('{} {}'.format(getattr(relative_uptime_seconds,k),k) for k in intervals if getattr(relative_uptime_seconds,k))

    with open('/proc/loadavg', 'r') as f:
        min_1_avg, min_5_avg, min_15_avg, processes, last_process = f.readline().split()
    load_averages = ' '.join(map(str, (min_1_avg, min_5_avg, min_15_avg)))

    with open('/proc/cpuinfo', 'r') as f:
        cpu_info = f.readlines()
    for info in cpu_info:
        if "model name" in info:
            cpu_model = info[13:].strip()
            break

    with open('/proc/meminfo', 'r') as f:
        mem_info = f.readlines()
    for info in mem_info:
        if "MemTotal" in info:
            title, mem_total_kb, unit = info.split()
            mem_total = ' '.join(map(str, (mem_total_kb, unit)))
        if "MemAvailable" in info:
            title, mem_avail_kb, unit = info.split()
            mem_avail = ' '.join(map(str, (mem_avail_kb, unit)))
        if "SwapTotal" in info:
            title, swap_total_kb, unit = info.split()
            swap_total = ' '.join(map(str, (swap_total_kb, unit)))
        if "SwapFree" in info:
            title, swap_free_kb, unit = info.split()
            swap_free = ' '.join(map(str, (swap_free_kb, unit)))

    return uptime, load_averages, cpu_model, mem_total, mem_avail, swap_total, swap_free


def get_os_basics():
    name = platform.node()
    distribution = ' '.join(map(str, distro.linux_distribution()))
    kernel_arch = ' '.join(map(str, (platform.release(), platform.machine())))
    local_ips = sanitize(check_output(['hostname', '--all-ip-addresses']))

    return name, distribution, kernel_arch, local_ips