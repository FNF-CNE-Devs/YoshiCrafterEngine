function create() {
	character.frames = Paths.getCharacter(character.curCharacter);
	character.loadJSON(true); // Setting to true will override getColors() and dance().
}