// cpu_temp — print the CPU temperature (°C, integer) for the bar's CPU pill.
//
// macOS has no sudo-free CLI for this on Apple Silicon, so read the SoC's
// thermal sensors straight from the IOHID event system (the same source the
// Stats app uses). Prints the average of the CPU die sensors and exits 1 if
// none are found. Built automatically by sketchybarrc (needs Xcode CLT):
//   clang -O2 -framework IOKit -framework CoreFoundation -o cpu_temp cpu_temp.c
//
// Sensor names: "PMU tdie1..N" on M2 and later (verified on M5),
// "pACC/eACC MTR Temp Sensor*" on M1.

#include <CoreFoundation/CoreFoundation.h>
#include <stdio.h>
#include <string.h>

typedef struct __IOHIDEvent *IOHIDEventRef;
typedef struct __IOHIDServiceClient *IOHIDServiceClientRef;
typedef struct __IOHIDEventSystemClient *IOHIDEventSystemClientRef;

IOHIDEventSystemClientRef IOHIDEventSystemClientCreate(CFAllocatorRef);
int IOHIDEventSystemClientSetMatching(IOHIDEventSystemClientRef, CFDictionaryRef);
CFArrayRef IOHIDEventSystemClientCopyServices(IOHIDEventSystemClientRef);
IOHIDEventRef IOHIDServiceClientCopyEvent(IOHIDServiceClientRef, int64_t, int32_t, int64_t);
CFTypeRef IOHIDServiceClientCopyProperty(IOHIDServiceClientRef, CFStringRef);
double IOHIDEventGetFloatValue(IOHIDEventRef, int32_t);

#define kIOHIDEventTypeTemperature 15
#define kTemperatureField (kIOHIDEventTypeTemperature << 16)

static int is_cpu_sensor(const char *name) {
  return strncmp(name, "PMU tdie", 8) == 0 || strstr(name, "ACC MTR Temp") != NULL;
}

int main(void) {
  int page = 0xff00, usage = 5;  // AppleVendor / TemperatureSensor
  CFNumberRef p = CFNumberCreate(NULL, kCFNumberIntType, &page);
  CFNumberRef u = CFNumberCreate(NULL, kCFNumberIntType, &usage);
  const void *keys[] = {CFSTR("PrimaryUsagePage"), CFSTR("PrimaryUsage")};
  const void *vals[] = {p, u};
  CFDictionaryRef match = CFDictionaryCreate(NULL, keys, vals, 2, &kCFTypeDictionaryKeyCallBacks,
                                             &kCFTypeDictionaryValueCallBacks);

  IOHIDEventSystemClientRef client = IOHIDEventSystemClientCreate(kCFAllocatorDefault);
  if (!client) return 1;
  IOHIDEventSystemClientSetMatching(client, match);
  CFArrayRef services = IOHIDEventSystemClientCopyServices(client);
  if (!services) return 1;

  double sum = 0;
  int n = 0;
  for (CFIndex i = 0; i < CFArrayGetCount(services); i++) {
    IOHIDServiceClientRef sc = (IOHIDServiceClientRef)CFArrayGetValueAtIndex(services, i);
    CFStringRef name = IOHIDServiceClientCopyProperty(sc, CFSTR("Product"));
    if (!name) continue;
    char buf[128];
    int ok = CFStringGetCString(name, buf, sizeof buf, kCFStringEncodingUTF8) && is_cpu_sensor(buf);
    CFRelease(name);
    if (!ok) continue;

    IOHIDEventRef ev = IOHIDServiceClientCopyEvent(sc, kIOHIDEventTypeTemperature, 0, 0);
    if (!ev) continue;
    double t = IOHIDEventGetFloatValue(ev, kTemperatureField);
    CFRelease(ev);
    if (t > 0 && t < 150) { sum += t; n++; }  // skip unplugged/garbage readings
  }

  if (n == 0) return 1;
  printf("%.0f\n", sum / n);
  return 0;
}
