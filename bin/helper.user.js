// ==UserScript==
// @name         PB2e: Copy proficiencies
// @namespace    https://yal.cc/
// @version      2026-09-10
// @description  For tool use
// @author       YellowAfterlife
// @match        https://pathbuilder2e.com/app.html*
// @grant        GM.registerMenuCommand
// @grant        GM.setClipboard
// ==/UserScript==

(function() {
    'use strict';
	function url2prof(url) {
		if (url.includes("legendary")) return 4;
		if (url.includes("master")) return 3;
		if (url.includes("expert")) return 2;
		if (url.includes("untrained")) return 0;
		if (url.includes("trained")) return 1;
		return 0;
	}
	function img2prof(img) {
		if (!img) return 0;
		return url2prof(img.src);
	}
	async function render() {
		return new Promise((resolve, reject) => {
			requestAnimationFrame(() => { resolve(true) });
		});
	}
	async function getProfs() {
		let tabs = [...document.querySelectorAll(`#tabbed-area > .tabbed-area-menu > .section-menu`)];
		function openTab(name) {
			let tab = tabs.find(tab => tab.innerText == name);
			tab.click();
		}
		//
		let out = {};

		// skills/DCs:
		function skillLabelToProf(label) {
			let parent = label.parentElement;
			return img2prof(parent.querySelector(`img:not(.dice-proficiency)`));
		}
		let skillLabels = [...document.querySelectorAll(`#container-section-skills .section-skill-name`)]
		out.classDC = skillLabelToProf(skillLabels[0]);
		out.perception = skillLabelToProf(skillLabels.find(l => l.innerText == "Perception"));

		//
		openTab("Weapons");
		let maxWeaponProf = 0;
		for (let div of document.querySelectorAll(`.weapon-name`)) {
			let img = div.previousElementSibling;
			maxWeaponProf = Math.max(maxWeaponProf, img2prof(img));
		}
		out.weapons = maxWeaponProf;

		//
		openTab("Defense");
		let armorDivs = document.querySelector(`.tabbed-area-top`).querySelectorAll(`.short-proficiency`);
		function armorToProf(div) {
			return img2prof(div.querySelector(`img`));
		}
		out.lightArmor = armorToProf(armorDivs[0]);
		out.mediumArmor = armorToProf(armorDivs[1]);
		out.heavyArmor = armorToProf(armorDivs[2]);
		out.unarmored = armorToProf(armorDivs[3]);
		out.armor = Math.max(out.lightArmor, out.mediumArmor, out.heavyArmor, out.unarmored);

		//
		openTab("Spells");
		document.querySelector(`#tabbed-area > .tabbed-area-menu + .submenu`).querySelector("div").click();
		out.spells = img2prof(document.querySelector(`#layout-parent-spellcasters .prof-section-holder img`));
		
		// saves:
		let saves = [
			...document.querySelector(`.defense-lines`).querySelectorAll(`.saves-button`)
		].map(b => b.querySelector(`img:not(.dice-proficiency)`)).map(img2prof);
		out.fortitude = saves[0];
		out.reflex = saves[1];
		out.will = saves[2];

		//
		return out;
	}
	async function getAllProfs() {
		let levelButton = document.querySelector(`.section-top`).querySelector(`.div-button > .button-text`);
		let prevLevel = parseInt(levelButton.nextElementSibling.innerText);
		async function setLevel(level) {
			levelButton.click();
			let levelButtons = document.querySelector(`#root.modal .button-bar`).querySelectorAll(`.div-button`);
			levelButtons[level - 1].click();
			await render();
		}
		let out = [];
		for (let level = 1; level <= 20; level++) {
			await setLevel(level);
			out.push(await getProfs());
		}
		await setLevel(prevLevel);
		return out;
	}
	GM.registerMenuCommand("Copy Proficiencies", async () => {
		const perLevel = await getAllProfs();
		const lines = perLevel.map(p => "\t" + JSON.stringify(p) + ",");
		const text = ["["].concat(lines, ["]"]).join("\n");
		await GM.setClipboard(text, "text");
	}, "p");
})();