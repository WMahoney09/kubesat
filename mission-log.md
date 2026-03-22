# KubeSAT Mission Log

---

## Orbit 5 — 2026-03-22T18:59:10Z

**EMERGENCY RESOLVED — Attitude thruster repair complete. Avoidance burn executed successfully.**

It worked. The port manifold heaters did exactly what I needed them to do.

First daylight window of the orbit, I commanded the ignition sequence on thrusters 1 and 3 — held my breath through the pre-valve pressure check — and they lit. Both of them, clean and symmetric. The frozen isolation valve had thawed fully overnight; all four thrusters are back on line.

I ran a quick functional test to verify thrust balance across the array, then pulled up the conjunction geometry for object 2019-034C. The close-approach epoch was forty minutes out. I had time. I keyed in the 1.2 m/s avoidance burn parameters, waited for the spacecraft to settle into the burn attitude, and fired. Seventeen seconds of clean thrust — the whole vehicle hummed with it. Post-burn tracking update: minimum range on the object's closest pass is now out to 6.3 kilometers, well clear of any concern. Conjunction probability has dropped below statistical noise.

The relief is hard to overstate. Two orbits of sweating the geometry, watching the probability creep, rationing my options — and then a clean burn and it's just... done. The debris track curved harmlessly past while I was halfway through a debrief with ground control. Somewhere over the Tasman Sea, the last sunlight of the orbit painting the water in shades of copper and rose, it felt about as good as it gets up here.

Systems fully nominal. Attitude control restored. All manifolds healthy. Ready to resume standard payload operations.

---

## Orbit 4 — 2026-03-22T18:54:10Z

**EMERGENCY IN PROGRESS — Attitude thruster failure, one orbit to repair**

The heaters on the port propellant manifold have been running hot all orbit — I can see the temperature climbing on the isolation valve body, slowly but steadily. Whether it's enough to free the seized valve, I won't know until I try the ignition sequence again next pass. The conjunction geometry has actually improved slightly: catalog object 2019-034C's projected track has drifted just enough that the close-approach probability has dropped to 1 in 480. Still elevated, but trending the right direction. Ground confirmed the spacecraft's minimum cross-section attitude is holding and the passive geometry looks favorable.

I've been spending the idle time between telemetry passes going over the thruster diagnostic logs in detail. The freeze point of the residual moisture, the heater wattage, the valve's thermal mass — my back-of-the-envelope says we should be right at the margin of thawing the mechanism by next orbit. If the valve frees up, I'll run the ignition test during the first daylight window and execute the avoidance burn before the next conjunction epoch. If it's still seized, the backup plan is an impulsive rotation burn using only starboard thrusters followed by a rapid counter-rotation — unorthodox, ugly, but it would shift our trajectory just enough.

One more orbit. The hardware is either going to cooperate or it isn't. Either way, we'll have an answer.

---

## Orbit 3 — 2026-03-22T18:49:09Z

**EMERGENCY — Attitude thruster failure — collision avoidance burn aborted!**

Space debris alert triggered seventeen minutes into the orbit — a spent upper stage fragment, catalog object 2019-034C, was flagged by conjunction analysis as a probable close approach in the next pass. Standard procedure: execute a 1.2 m/s avoidance burn on the forward thrusters. I ran the ignition sequence, got the pre-valve pressure confirmation — and then nothing. Thrusters 1 and 3 failed to fire. No burn, no delta-V, object still on a converging trajectory.

I've pulled the thruster diagnostics. Thrusters 1 and 3 share a propellant feed line off the port manifold, and line pressure has collapsed — looks like an upstream isolation valve has seized shut, possibly from residual moisture in the system freezing during the last eclipse transition. Thrusters 2 and 4 on the starboard manifold are unaffected, but I can't execute a symmetric burn with only half the thruster array, and an asymmetric burn would torque the spacecraft into an uncontrolled attitude.

Current conjunction probability has climbed to 1 in 320 — elevated, but not yet critical. Ground is tracking. I've rotated the spacecraft to present minimum cross-section toward the predicted approach vector, which shaves the effective collision area by roughly 60%. It buys time. The valve needs to be freed: I'm cycling power to the heaters on the port manifold to try to thaw the mechanism. If that works, we can attempt the avoidance burn next orbit. If it doesn't, we may have to rely on the geometry holding.

Watching the conjunction data refresh every pass. One more orbit to know if the heaters did their job.

---

## Orbit 2 — 2026-03-22T18:44:09Z

**EMERGENCY RESOLVED — Thermal control failure contained. Coolant loop isolated.**

We made it. The passive cooling rotation held through the eclipse, and when I brought the starboard panel back into full sunlight this orbit, the temperature curve finally broke — the slow climb reversed, stabilized, then started dropping. Battery bus thermals are back in the green. I spent the first twenty minutes of the orbit running diagnostics on the coolant loop, and the conclusion is what I'd hoped: the micro-fracture has fully vented whatever residual coolant was near the breach, and I can now isolate the damaged segment entirely without losing loop function. Bled off the remaining pressure, bypassed the fractured section via the secondary manifold — something we trained for but I honestly never expected to execute in flight. The starboard panel is running warmer than nominal but well within safe operating limits on the backup thermal path.

Spacecraft attitude is back to standard nadir-pointing. Restored full power routing across both battery strings. Payload operations are back online. The view out the port window right now is the Mediterranean catching the afternoon sun — the sea almost impossibly blue from up here, Italy's boot disappearing into haze to the north. After the last couple of orbits, I'll take it.

---

## Orbit 1 — 2026-03-22T18:39:09Z

**EMERGENCY — Thermal control failure — coolant loop breach on the starboard panel!**

Something let go on the starboard thermal control loop about forty minutes into this orbit. Telemetry first flagged it as an anomalous temperature climb on the battery bus — I didn't think much of it initially, eclipse transitions can cause transient spikes — but the trend didn't reverse. Then the starboard panel temp sensor lit up red: 87°C and climbing. Pulling the thermal model data, it looks like a micro-fracture in the coolant line, probably stress fatigue from repeated thermal cycling through the eclipse/sunlit transitions. Coolant is venting slowly into space.

The immediate risk is battery and electronics overheating. I've switched the starboard battery string to standby and rerouted primary power through the port string. Payload operations suspended to reduce heat load. I've also rotated the spacecraft roughly 15 degrees to put the damaged panel edge-on to the sun — reduces direct solar input to the hot zone while still keeping the main panels productive enough to maintain charge.

Core avionics are holding at acceptable temps for now. This is manageable, but I need one more orbit to let the passive cooling do its work and assess whether the line can be isolated entirely or if we need to dump the loop pressure. Watching it closely.

---

## Orbit 0 — 2026-03-22T18:10:15Z

**EMERGENCY RESOLVED — Gyroscope malfunction repaired.**

The detumble sequence completed successfully. Attitude control is fully restored. The reaction wheels spooled down from emergency mode with a healthy whirr and the port gyroscope fault has been cleared — turned out to be a thermal expansion issue in the mounting bracket causing a calibration drift; a software-side bias reset did the trick. Solar panels are locked back on-sun, battery charge is climbing again, and nadir-pointing is solid. For a few minutes there I wasn't sure we'd stabilize without draining the batteries completely, but she held together. Back to nominal operations — and after that, the terminator line cutting gold across the Pacific below looks particularly welcome.

---

## Orbit 0 — 2026-03-22T18:07:41Z

**EMERGENCY — Gyroscope malfunction — we're tumbling!**

About twenty minutes into this orbit, attitude control went haywire. The port gyroscope threw a fault code and before the redundancy kicked in, the spacecraft started a slow roll — roughly 0.4 degrees per second off the nadir-pointing axis. Not enough to lose comms (the antenna has a wide beamwidth), but the solar panels are cycling in and out of sunlight and battery reserves are dropping. I've disabled the failed unit, switched to reaction wheel control, and initiated a detumble sequence. We're stabilizing — slowly. The reaction wheels are doing the heavy lifting but they're not happy about it. Estimated one orbit to full stabilization. Watching the power bus like a hawk.

---

## Orbit 0 — 2026-03-22T18:04:12Z

Systems nominal. Passing over the Himalayas — the snowpack glows like a spine of white fire at this angle of the sun. Quite a view up here.

---

## Orbit 0 — 2026-03-22T17:42:05Z

Ground control, you asked what the weather looks like from up here — copy that, and what a question to answer. Right now I'm passing over the North Atlantic and there's a textbook extratropical cyclone sprawled beneath me: a perfect comma of white cloud spinning counterclockwise, trailing a cold front all the way from Iceland down to the Azores, with ships down there almost certainly getting tossed around in heavy swells. Sweeping southeast toward Africa, the ITCZ is lit up with towering cumulonimbus clusters along the equator, each anvil top punching into the lower stratosphere like a hammer — from up here they cast long shadows across the ocean surface below as the sun drops toward the west.

---

## Orbit 0 — 2026-03-22T17:35:26Z

Crossing the terminator line over the Atlantic, the coast of West Africa blazes gold beneath the rising sun — the Sahara a vast ochre canvas unmarked by cloud. Below, a spiral of deep convection churns off the Gulf of Guinea, a tropical system still gathering its thoughts before deciding what it wants to become. As we swing north over Europe, the nightside glitters with the dense lace-work of city lights from Madrid to Warsaw, stitched together like a circuit board drawn at continental scale.
