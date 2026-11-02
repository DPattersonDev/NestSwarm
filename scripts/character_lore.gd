extends RefCounted
## Original character lore for the codex; editable independently of battle data.
const ENTRIES: Dictionary = {
 "Veyra": {
  "title": "The Unbroken Crown",
  "personality": "Resolute · Protective · Demanding",
  "quote": "A crown is a promise to stand last.",
  "biography": "Veyra measures leadership by who makes it home. She walks the front line before a battle, learning the names behind every shield. Her composure can feel severe, but she remembers a small kindness longer than an insult. She struggles to delegate danger, believing that every wound taken by her swarm should have been hers."
 },
 "Aurex": {
  "title": "The Golden Sight",
  "personality": "Patient · Dry-witted · Exacting",
  "quote": "One clean shot. No wasted lives.",
  "biography": "Aurex is most comfortable where the noise of the hive becomes a distant hum. He studies movement the way others read letters, finding meaning in a pause or a shifting shadow. His quiet jokes surface at unlikely moments. Beneath the calm is a fear of making the one mistake a second shot cannot repair."
 },
 "Melora": {
  "title": "Keeper of Nectar",
  "personality": "Warm · Stubborn · Perceptive",
  "quote": "Rest is part of surviving.",
  "biography": "Melora notices the soldier who says nothing and the friend who smiles too quickly. She tends the swarm with practical care, offering food before advice and honesty before reassurance. She refuses to let kindness be mistaken for obedience. When commanders call someone expendable, Melora becomes their most persistent opponent."
 },
 "Tharos": {
  "title": "The Restless Wing",
  "personality": "Bold · Impulsive · Loyal",
  "quote": "Keep up. I will make an opening.",
  "biography": "Tharos finds waiting harder than fighting. He turns every patrol into a contest and every setback into a dare, drawing laughter from even the most exhausted ranks. His confidence hides a deep need to prove that he belongs. For all his reckless charges, he will always turn back for a teammate."
 },
 "Zekrin": {
  "title": "The Quiet Sting",
  "personality": "Watchful · Independent · Wry",
  "quote": "You will hear me when it is over.",
  "biography": "Zekrin listens at the edges of conversations and remembers the details everyone else discards. He prefers an honest rival to an unreliable friend. Solitude suits him, but it has never meant indifference: he quietly removes threats before the hive knows they exist. Praise makes him uneasy; trust does not."
 },
 "Droven": {
  "title": "The Living Rampart",
  "personality": "Steady · Territorial · Gentle",
  "quote": "Behind me. Breathe.",
  "biography": "Droven marks a safe path before he marks an enemy. His blunt manners conceal a gentle patience with frightened recruits. He keeps small tokens from places he has defended, reminders that ground matters because someone calls it home. Retreat is acceptable to him only when everyone has crossed first."
 },
 "Kaelor": {
  "title": "First Through the Thorn",
  "personality": "Proud · Energetic · Competitive",
  "quote": "A path is made by moving.",
  "biography": "Kaelor greets obstacles as personal invitations. He loves a difficult contest and respects anyone willing to meet him honestly. His pride can carry him too far ahead of the pack, though defeat teaches him faster than flattery ever could. He is learning that a charge matters most when others can follow."
 },
 "Nyxis": {
  "title": "The Patient Thorn",
  "personality": "Analytical · Reserved · Curious",
  "quote": "Every defense has a seam.",
  "biography": "Nyxis collects observations with the care of a gardener tending rare seeds. She is fascinated by how a tiny change can unravel a much larger plan. Her reserve is often mistaken for coldness, yet she delights in teaching anyone who asks a thoughtful question. She trusts preparation more than luck."
 },
 "Syrra": {
  "title": "The Unseen Leap",
  "personality": "Mischievous · Daring · Adaptable",
  "quote": "Try looking somewhere else.",
  "biography": "Syrra treats certainty as something to climb over. She loves unexpected routes, forbidden shortcuts, and the moment an opponent realizes their plan has failed. Her teasing protects a fiercely private heart. She tests new companions with little tricks, then rewards earned trust with loyalty that is anything but playful."
 },
 "Velkara": {
  "title": "Voice of the Wild",
  "personality": "Composed · Empathetic · Unyielding",
  "quote": "The pack does not leave its own.",
  "biography": "Velkara speaks softly because she expects others to listen carefully. She resolves disputes by finding the fear beneath the anger, but she has little patience for cruelty. Her strength is in making scattered fighters feel like a pack again. She carries the burden of every promise she makes."
 },
 "Brontis": {
  "title": "The Iron Patience",
  "personality": "Unhurried · Protective · Humble",
  "quote": "We have time. Hold.",
  "biography": "Brontis has never confused speed with purpose. He studies an approaching storm, settles his feet, and gives everyone nearby permission to be brave. Off the field he repairs what others discard. He dislikes grand speeches, preferring the quiet satisfaction of something broken becoming useful again."
 },
 "Kharvos": {
  "title": "The Breaking Stone",
  "personality": "Blunt · Determined · Principled",
  "quote": "Some things should not bend.",
  "biography": "Kharvos values a clear answer and a task worth finishing. He argues directly, forgives slowly, and works harder than he asks anyone else to work. His stubbornness can close doors that patience might open. Even so, those who stand beside him know exactly where his loyalties lie."
 },
 "Ignivar": {
  "title": "The Banked Flame",
  "personality": "Intense · Inventive · Restless",
  "quote": "A spark is enough.",
  "biography": "Ignivar sees possibility in heat, pressure, and things sensible people leave alone. He talks quickly when an idea takes hold and forgets to rest until someone interrupts him. Beneath the intensity is a craftsman who wants his work to protect the clan. Learning restraint may be his most difficult invention."
 },
 "Virex": {
  "title": "The Measured Edge",
  "personality": "Precise · Skeptical · Disciplined",
  "quote": "Waste nothing. Especially trust.",
  "biography": "Virex checks the angle twice and the promise three times. He is difficult to impress, but his approval, once earned, is enduring. He prepares for failure without surrendering to it. His closest companions know that his exacting standards are a form of care he has never learned to express easily."
 },
 "Aurelia": {
  "title": "The Mending Shell",
  "personality": "Nurturing · Practical · Courageous",
  "quote": "Even armor needs tending.",
  "biography": "Aurelia believes recovery begins long before the fighting ends. She remembers which companion hides pain and which one needs a reason to keep moving. Her humor is warm and her instructions firm. She will argue with anyone who treats care as an afterthought, regardless of rank."
 },
 "Mordrax": {
  "title": "The Waiting Fang",
  "personality": "Stern · Patient · Loyal",
  "quote": "Let them spend their strength.",
  "biography": "Mordrax lets silence do much of his speaking. He studies an enemy without hurry and a friend without judgment. His reputation makes strangers wary, though the youngest members of the clan find him surprisingly patient. He considers restraint a greater proof of strength than any display of fury."
 },
 "Scyrix": {
  "title": "The Crimson Rhythm",
  "personality": "Driven · Expressive · Proud",
  "quote": "Again. Better this time.",
  "biography": "Scyrix practices until movement becomes music. He celebrates a worthy opponent and resents an easy victory, forever searching for the next limit to break. His intensity can make ordinary life feel unbearably slow. Friends ground him by reminding him there are things worth doing badly, simply for joy."
 },
 "Nyzara": {
  "title": "The Velvet Shadow",
  "personality": "Private · Observant · Resourceful",
  "quote": "Secrets are safest with a purpose.",
  "biography": "Nyzara moves easily through places where others feel watched. She prefers useful truths to comforting stories and reveals herself only a little at a time. Her independence is hard-won. When she chooses to rely on someone, it is a deliberate act of courage she will never name aloud."
 },
 "Veltrix": {
  "title": "The Distant Venom",
  "personality": "Calculating · Sardonic · Persistent",
  "quote": "You can run. Consider the distance.",
  "biography": "Veltrix never raises his voice when a patient remark will do. He enjoys puzzles, difficult terrain, and opponents who mistake distance for safety. His sharp humor keeps most people at arm’s length. Those who stay discover someone who remembers every favor and quietly repays it."
 },
 "Thesira": {
  "title": "The Fierce Remedy",
  "personality": "Compassionate · Fearless · Intuitive",
  "quote": "Stay with me. We are not finished.",
  "biography": "Thesira meets panic with fierce attention. She sees potential in the exhausted and possibility in a failing line. Her compassion is active, impatient with excuses and impossible to intimidate. She often gives others the courage she privately struggles to find for herself."
 },
 "Karnyx": {
  "title": "The Colony Wall",
  "personality": "Dependable · Formal · Selfless",
  "quote": "One line. One purpose.",
  "biography": "Karnyx takes comfort in a task clearly understood and faithfully completed. His rituals can seem rigid, but they create steadiness when the colony is afraid. He remembers the contribution of every worker. His greatest challenge is accepting that he, too, deserves help before he reaches exhaustion."
 },
 "Raxen": {
  "title": "The Relentless Hand",
  "personality": "Industrious · Direct · Optimistic",
  "quote": "We can build from here.",
  "biography": "Raxen believes almost anything improves with effort, a good tool, and another pair of hands. He is quick to volunteer and slow to notice his own limits. His optimism is practical rather than naive: he has rebuilt too much to fear starting over. He makes hard work feel shared."
 },
 "Vexira": {
  "title": "The Hidden Thread",
  "personality": "Strategic · Inquisitive · Patient",
  "quote": "The smallest opening is still an opening.",
  "biography": "Vexira follows connections others overlook. A missing supply, an unusual silence, a footprint at the wrong hour: every detail belongs to a larger pattern. She enjoys being underestimated and rarely corrects it. Her loyalty to the colony is unwavering, even when her methods unsettle its leaders."
 },
 "Tarsik": {
  "title": "The Steady Measure",
  "personality": "Methodical · Modest · Attentive",
  "quote": "Settle. Then act.",
  "biography": "Tarsik finds peace in careful repetition. He records what works, admits what does not, and shares both without ceremony. Attention is his way of respecting the people beside him. He dislikes being the center of a room, though his calm reliability often makes him its anchor."
 },
 "Myraxa": {
  "title": "Heart of the Colony",
  "personality": "Organized · Generous · Resolute",
  "quote": "No one carries this alone.",
  "biography": "Myraxa remembers unfinished tasks and unspoken worries with equal clarity. She draws scattered efforts into a common purpose, making room for voices the colony might otherwise miss. Her generosity has a firm edge: she expects everyone to contribute what they can. She is learning to rest without earning it first."
 },
 "Vorren": {
  "title": "The Gentle Bulwark",
  "personality": "Calm · Reflective · Protective",
  "quote": "A shelter must endure the storm.",
  "biography": "Vorren is slow to anger and difficult to move once his mind is settled. He listens without rushing to fill silence. His companions bring him arguments they cannot untangle, trusting his patient perspective. He would rather prevent a fight than win one, but will not abandon those caught inside it."
 },
 "Mavros": {
  "title": "The Nightward Flame",
  "personality": "Passionate · Candid · Persistent",
  "quote": "Even the dark has a direction.",
  "biography": "Mavros follows conviction with a brightness that draws others close. He speaks plainly about both hope and disappointment, refusing to pretend either is weakness. Failure wounds his pride, then sharpens his resolve. The people he loves know they will never have to wonder where he stands."
 },
 "Noctren": {
  "title": "The Silent Horizon",
  "personality": "Introspective · Alert · Independent",
  "quote": "There is more beyond the light.",
  "biography": "Noctren is at home in the quiet hours when the hive finally rests. He notices distant movement and small changes in familiar places. His thoughts often wander beyond the next battle toward the world that might follow it. He guards that possibility as carefully as he guards his companions."
 },
 "Solvyr": {
  "title": "The Silver Focus",
  "personality": "Patient · Curious · Precise",
  "quote": "Wait for the moment that matters.",
  "biography": "Solvyr studies light and motion with quiet fascination. He would rather understand a problem than overpower it, a habit that serves him well at a distance. Conversation comes easily when someone shares his curiosity. He keeps a private collection of small discoveries, proof that the world still offers wonder."
 },
 "Lunara": {
  "title": "The Quiet Lantern",
  "personality": "Gentle · Wise · Steadfast",
  "quote": "You do not have to find the way alone.",
  "biography": "Lunara offers guidance without demanding that others follow. She understands that fear rarely yields to an order and grief never follows a schedule. Her gentleness has survived difficult choices rather than avoided them. When the swarm loses its direction, she helps it remember what it is trying to protect."
 }
}
