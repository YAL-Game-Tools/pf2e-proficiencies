// A Foundry VTT macro!
let packs = game.packs.filter(p => p.metadata.type == "Item");
let indexes = await Promise.all(packs.map(p => p.getIndex()));
//
let uuids = [];
for (let pack of packs) for (let item of pack.index) if (item.type == "class") {
  uuids.push(item.uuid);
}
//
let arr = [];
for (let i = 0, n = uuids.length; i < n; i++) {
  let cl = await fromUuid(uuids[i]);
  let sys = cl.system;
  arr.push({
    name: cl.name,
    hp: sys.hp,
    kas: sys.keyAbility.value,
    defenses: sys.defenses,
    attacks: sys.attacks,
    skills: sys.trainedSkills,
  });
}
let lines = arr.map(a => "\t" + JSON.stringify(a) + ",");
lines.unshift("["); lines.push("]");
console.log(lines.join("\n"))