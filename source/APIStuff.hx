package;

class APIStuff
{
	//newgrounds API
	public static var API:String = "";
	public static var EncKey:String = "";

	//JOELwindows7: how about we build constructor that loads the file we can safely gitignore
	//without having to gitignore this class instead?
	/*
	public function new() {
		
	}
	*/
	//damn this awkward. why make class consist of just variable?
	//why not just have mere JSON file, so you can leave the API instantiatable and publishable publicly?
	//while leave the JSON file gitignored?
	//no you can't! that will be accessible through any means!
	//well then isn't when this executable disassembled that they could achieve the similar?
	//yeah I know, but we got to minimize the possibility as much as possible.
	//so code this in!
}
