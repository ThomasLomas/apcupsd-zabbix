This is a simple Ubuntu base with <code>apcupsd</code> installed.

<b>Use Case :</b><br>
Use this image if your UPS is connected to your docker host by USB Cable and you don't want to run <code>apcupsd</code> in the physical host OS.

The purpose of this image was to containerise the APC UPS monitoring daemon so that it is separated from the OS, yet still has access to the UPS via USB Cable.  

It is not necessary to run this container in <code>privileged</code> mode.  Instead, we attach only the specific USB Device to the container using the <code>--device</code> directive in teh <code>docker run</code> command.

Other apcupsd images i've seen are for exporting monitoring data to grafana or prometheus, this image does not do that, though it does expose port 3551 to the network allowing for the apcupsd monitorig data to be captured using those other images.


<b>Configuration :</b>

Very little configuration is currently required for this image to work, though you may be required to tweak the USB device that is passed through to your container by docker.

<code>
docker run -it 
  --name=apcupsd 
  -e TZ=Europe/London 
  --device=/dev/usb/<b>hiddev1</b>
  --restart unless-stopped
  -p=3551:3551
  gregewing/apcupsd:latest
</code>
<br>
<br>

<b>Notes</b><br>
<ul type="disc">
<li>In case you're interested, I discovered that (at least my Smart UPS 3000) reports itself over USB as a <code>usbhid</code> device.  I discovered this by running <code>usb-devices</code> at the linux command line on the physical host that is connected to the UPS by USB, which told me the device type.  Looking in <code>/dev/usb/</code> I only had two to choose from, so I was able to hit on the correct one pretty quickly.  I don't yet know if this will change dynamically at reboot of the host.  Here's hoping it's reasonably static.</li>
<li>Testing was done by running the <code>apcaccess</code> on the physical host, and in the container, though you likely only need to run it in the container, afterall, we don't want the APC UPS software installed in the host, that's the point of this image after all.  if the test is successful, then the output from <code>apcaccess</code> is quite a bit different compared with a fail scenario.  the difference should be self explanatory. This lets us know that the <code>apcupsd</code> daemon successfully connected to the UPS over the USB cable.  If all is well, port 3551 should also be exposed to the network allowing other systems to take a heartbeat signal from the UPS via this container.</li>
<li>You may wish to customise the <code>apcupsd.conf</code> file in <code>/etc/apcupsd/</code> but i'm pretty sure that the default settings are fine for most implementations.  The one exception may be the <code>UPSNAME</code> directive which you may wish to customise, but it doesnt appear to have a bearing on anything in my environment.</li>
</ul>

<b>To Do</b><br>
<ul type="disc">
<li>Check whether or not the container has the capability to gracefully shut down the physical host if there is a prolonged power failure. I've seen a few other apcupsd images that seem to have this ability so I imagine it's doable.</li>
</ul>
