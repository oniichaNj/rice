#define _BSD_SOURCE
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include <strings.h>
#include <sys/time.h>
#include <time.h>
#include <sys/types.h>
#include <sys/wait.h>

#include <X11/Xlib.h>

#define MAX_ARP_CACHE_ENTRIES  1024

char *tzberlin = "Europe/Berlin";

static Display *dpy;

char *
smprintf(char *fmt, ...)
{
	va_list fmtargs;
	char *ret;
	int len;

	va_start(fmtargs, fmt);
	len = vsnprintf(NULL, 0, fmt, fmtargs);
	va_end(fmtargs);

	ret = malloc(++len);
	if (ret == NULL) {
		perror("malloc");
		exit(1);
	}

	va_start(fmtargs, fmt);
	vsnprintf(ret, len, fmt, fmtargs);
	va_end(fmtargs);

	return ret;
}


float getfreq(char *file) {
  FILE *fd;
  char *freq;
  float ret;

  freq = malloc(10);
  fd = fopen(file, "r");
  if(fd == NULL) {
    fprintf(stderr, "Cannot open '%s' for reading.\n", file);
    exit(1);
  }

  fgets(freq, 10, fd);
  fclose(fd);

  ret = atof(freq)/1000000;
  free(freq);
  return ret;
}




int getbattery() {
	FILE *fd;
	int energy_now, energy_full, voltage_now;

	fd = fopen("/sys/class/power_supply/BAT0/energy_now", "r");
	if(fd == NULL) {
		fprintf(stderr, "Error opening energy_now.\n");
		return -1;
	}
	fscanf(fd, "%d", &energy_now);
	fclose(fd);


	fd = fopen("/sys/class/power_supply/BAT0/energy_full", "r");
	if(fd == NULL) {
		fprintf(stderr, "Error opening energy_full.\n");
		return -1;
	}
	fscanf(fd, "%d", &energy_full);
	fclose(fd);


	fd = fopen("/sys/class/power_supply/BAT0/voltage_now", "r");
	if(fd == NULL) {
		fprintf(stderr, "Error opening voltage_now.\n");
		return -1;
	}
	fscanf(fd, "%d", &voltage_now);
	fclose(fd);


	return ((float)energy_now * 1000 / (float)voltage_now) * 100 / ((float)energy_full * 1000 / (float)voltage_now);
}


void
settz(char *tzname)
{
	setenv("TZ", tzname, 1);
}

char *
mktimes(char *fmt, char *tzname)
{
	char buf[129];
	time_t tim;
	struct tm *timtm;

	memset(buf, 0, sizeof(buf));
	settz(tzname);
	tim = time(NULL);
	timtm = localtime(&tim);
	if (timtm == NULL) {
		perror("localtime");
		exit(1);
	}

	if (!strftime(buf, sizeof(buf)-1, fmt, timtm)) {
		fprintf(stderr, "strftime == 0\n");
		exit(1);
	}

	return smprintf("%s", buf);
}

void
setstatus(char *str)
{
	XStoreName(dpy, DefaultRootWindow(dpy), str);
	XSync(dpy, False);
}

char *
loadavg(void)
{
	double avgs[3];

	if (getloadavg(avgs, 3) < 0) {
		perror("getloadavg");
		exit(1);
	}

	return smprintf("%.2f %.2f %.2f", avgs[0], avgs[1], avgs[2]);
}


char *detect_arp_spoofing(void) {

  FILE *fp;
  int  i = 1, j;
  char **ptr = NULL;
  char buf[100], *mac[MAX_ARP_CACHE_ENTRIES];

  if (!(fp = fopen("/proc/net/arp", "r"))) {
    return NULL;
  }

  ptr = mac;

  while (fgets(buf, sizeof(buf) - 1, fp)) {

    /* ignore the first line. */
    if (i == 1) { i = 0; continue; }

    if ((*ptr = malloc(18)) == NULL) {
      return NULL;
    }

    sscanf(buf, "%*s %*s %*s %s", *ptr);
    ptr++;
  }

  /* end table with a 0. */
  *ptr = 0;

  fclose(fp);

  for (i = 0; mac[i] != 0; i++)
    for (j = i + 1; mac[j] != 0; j++)
      if ((strcmp("00:00:00:00:00:00", mac[i]) != 0) &&
          (strcmp(mac[i], mac[j]) == 0)) {

        return "\033[48;5;196mDetected MITM!\033[0m";
      }

  return "MITMp enabled.";
}




int
main(void)
{
	char *status;
	char *avgs;
	char *tmbln;
	char *mitm;
	int  batt;
	float cpu0, cpu1;
	if (!(dpy = XOpenDisplay(NULL))) {
		fprintf(stderr, "dwmstatus: cannot open display.\n");
		return 1;
	}

	for (;;sleep(5)) {
		avgs = loadavg();
		tmbln = mktimes("%a %d %b %H:%M %Z %Y", tzberlin);
		batt = getbattery();
		mitm = detect_arp_spoofing();
                cpu0 = getfreq("/sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq");
                cpu1 = getfreq("/sys/devices/system/cpu/cpu1/cpufreq/scaling_cur_freq");
	

        	status = smprintf("Freq: (%0.2f|%0.2f) | Battery: %i % | %s | Load: %s | %s",
				  cpu0, cpu1, batt, mitm, avgs, tmbln);

		if (batt <= 20) {
		  status = smprintf("Freq: (%0.2f|%0.2f) |\033[48;5;196m Battery: %i % \033[0m| %s | Load: %s | %s",
				    cpu0, cpu1, batt, mitm, avgs, tmbln);
		}

		setstatus(status);
		free(avgs);
		free(tmbln);
		free(status);
	}

	XCloseDisplay(dpy);

	return 0;
}
