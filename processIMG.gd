extends Node

@export var openDialogue: FileDialog
@export var palDialogue: FileDialog
@export var placeholderTexRect: TextureRect
@export var paletteIMGContainer: VBoxContainer
@export var respritedIMGContainer: VBoxContainer

var loadedImage: Image
var loadedPalImage: Image
var palHBoxScene = load("res://pal_import_h_box_container.tscn")
@export var initialisedPalHBox: HBoxContainer
var childPalTextRect: TextureRect

var repalColorArray: Array[Array]

#pre-baked RGB vals to hot swap
var recolKeyShade1: Vector3i = Vector3i(232,239,242)
var recolKeyShade2: Vector3i = Vector3i(207,215,220)
var recolKeyShade3: Vector3i = Vector3i(167,178,203)
var recolKeyShade4: Vector3i = Vector3i(136,152,186)
var recolKeyShade5: Vector3i = Vector3i(106,121,160)
var recolKeyShade6: Vector3i = Vector3i(93,95,133)
var recolKeyShade7: Vector3i = Vector3i(70,74,113)
var recolKeyShade8: Vector3i = Vector3i(50,57,89)
var recolKeyShade9: Vector3i = Vector3i(34,40,63)

#var exampleRecol1: Vector3i = Vector3i(200,100,200) #purplish
var recolTarget1: Color = Color.BLACK
var recolTarget2: Color = Color.BLACK
var recolTarget3: Color = Color.BLACK
var recolTarget4: Color = Color.BLACK
var recolTarget5: Color = Color.BLACK
var recolTarget6: Color = Color.BLACK
var recolTarget7: Color = Color.BLACK
var recolTarget8: Color = Color.BLACK
var recolTarget9: Color = Color.BLACK

var folderPathString = OS.get_system_dir(OS.SYSTEM_DIR_DESKTOP)
var currentImgExportNum: int = 0
var importIMGName: String = ""

var called : int = 0
var recolTargArray: Array[String] = []
var imgName: String = ""

func createExportFolderIfNone():
	if not DirAccess.dir_exists_absolute(folderPathString + "/Repal_Exports"):
		DirAccess.make_dir_absolute(folderPathString + "/Repal_Exports")
	else:
		folderPathString = folderPathString + "/Repal_Exports"
	pass

func _on_button_down():
	if(repalColorArray != []): openDialogue.popup_centered_ratio()

func _on_upload_pal_button_button_down():
	createExportFolderIfNone()
	palDialogue.popup_centered_ratio()

func _on_file_dialog_file_selected(path):
	loadedImage = Image.new()
	loadedImage.load(path)

	var pathStringArray = path.split("/", true)
	print(pathStringArray[-1])
	imgName = pathStringArray[-1]
	#correctly prints filename.extension using -1 which indexes from the back of the array (the last element)
	
		#loadedImage data format:
		# { "width": 128, "height": 80, "format": "RGBA8", 
		#   "mipmaps": false, "data": [0, 0, 0, 0 ...  etc - R, G, B, A vals per pixel.
	var tex = ImageTexture.create_from_image(loadedImage)
	placeholderTexRect.texture = tex

	var currentSegDepth: int = 0
	for i in repalColorArray.size():
		for a in repalColorArray[i].size():
			currentSegDepth += 1
			if(currentSegDepth == 1): recolTarget1 = repalColorArray[i][a]
			if(currentSegDepth == 2): recolTarget2 = repalColorArray[i][a]
			if(currentSegDepth == 3): recolTarget3 = repalColorArray[i][a]
			if(currentSegDepth == 4): recolTarget4 = repalColorArray[i][a]
			if(currentSegDepth == 5): recolTarget5 = repalColorArray[i][a]
			if(currentSegDepth == 6): recolTarget6 = repalColorArray[i][a]
			if(currentSegDepth == 7): recolTarget7 = repalColorArray[i][a]
			if(currentSegDepth == 8): recolTarget8 = repalColorArray[i][a]
			if(currentSegDepth == 9): recolTarget9 = repalColorArray[i][a]
		currentSegDepth = 0
		redrawPixels()


func _on_file_dialog_for_pal_file_selected(path):
	loadedPalImage = Image.new()
	loadedPalImage.load(path)
	
	var nonPackedArray: Array[int]
	nonPackedArray.assign(loadedPalImage.data.data)
	
	var quadSet: int = 0
	var ninePal: int = 0
	var finishedSegment: bool = false
	var _r: int = 0
	var _g: int = 0
	var _b: int = 0
	var _a: int = 0
	var instance = initialisedPalHBox
	
	var foundFirstCol: bool = false
	var segmentRecolArr: Array[Color]
	for i in nonPackedArray.size():
		quadSet += 1
		if(quadSet == 1):
			_r = nonPackedArray[i]
		if(quadSet == 2):
			_g = nonPackedArray[i]
		if(quadSet == 3):
			_b = nonPackedArray[i]
		if(quadSet == 4):
			_a = nonPackedArray[i]

			quadSet = 0

			var checkStr = str(_r) + str(_g) + str(_b)
			if(checkStr == "000" || checkStr == "255255255"): 
				finishedSegment = true
				ninePal = 0
				#we want to add to var segmentRecolArr: Array[Color] = [] 
				#the FIRST time we hit this block ^ after adding at least one col, cheeky bool?
				if(foundFirstCol): 
					if segmentRecolArr != []: repalColorArray.append(segmentRecolArr.duplicate())
					segmentRecolArr.clear()

			else:
				if(finishedSegment):
					instance = palHBoxScene.instantiate()
					paletteIMGContainer.add_child(instance)
					finishedSegment = false
				if(ninePal == 9):
					instance = palHBoxScene.instantiate()
					paletteIMGContainer.add_child(instance)
					print("ninepal made new segment")
					ninePal = 0
				
				var newPalIMG = Image.create_empty(1,1,false,Image.FORMAT_RGBA8)
				newPalIMG.fill(Color.from_rgba8(_r,_g,_b, _a))
				childPalTextRect = instance.get_child(ninePal)
				childPalTextRect.texture = ImageTexture.create_from_image(newPalIMG)
				ninePal+= 1
				foundFirstCol = true
				var colToAdd: Color = Color.from_rgba8(_r,_g,_b, _a)

				segmentRecolArr.append(colToAdd)


func redrawPixels():
	var quadSet: int = 0

	var nonPackedArray: Array[int]
	nonPackedArray.assign(loadedImage.data.data)
	
	var _r: int = 0
	var _g: int = 0
	var _b: int = 0
	var _a: int = 0
	var segmentSize: int = 0
	var nonPackedArrayDupe = nonPackedArray.duplicate()
	
	#Iterate over every each pixel entry in the array
	# r on quadset 1
	# g on quadset 2
	# b on quadset 3
	# a (alpha) on quadset 4 (unedited for transparency support)
	for i in nonPackedArray.size():
		quadSet += 1
		
		if(quadSet == 1):
			if(nonPackedArrayDupe[i] == recolKeyShade1.x 
			&& nonPackedArrayDupe[i+1] == recolKeyShade1.y
			&& nonPackedArrayDupe[i+2] == recolKeyShade1.z
			&& recolTarget1 != Color.BLACK): nonPackedArray[i] = recolTarget1.r8
			
			if(nonPackedArrayDupe[i] == recolKeyShade2.x 
			&& nonPackedArrayDupe[i+1] == recolKeyShade2.y
			&& nonPackedArrayDupe[i+2] == recolKeyShade2.z
			&& recolTarget2 != Color.BLACK): nonPackedArray[i] = recolTarget2.r8
			
			if(nonPackedArrayDupe[i] == recolKeyShade3.x 
			&& nonPackedArrayDupe[i+1] == recolKeyShade3.y
			&& nonPackedArrayDupe[i+2] == recolKeyShade3.z
			&& recolTarget3 != Color.BLACK): nonPackedArray[i] = recolTarget3.r8
			
			if(nonPackedArrayDupe[i] == recolKeyShade4.x 
			&& nonPackedArrayDupe[i+1] == recolKeyShade4.y
			&& nonPackedArrayDupe[i+2] == recolKeyShade4.z
			&& recolTarget4 != Color.BLACK): nonPackedArray[i] = recolTarget4.r8
			
			if(nonPackedArrayDupe[i] == recolKeyShade5.x 
			&& nonPackedArrayDupe[i+1] == recolKeyShade5.y
			&& nonPackedArrayDupe[i+2] == recolKeyShade5.z
			&& recolTarget5 != Color.BLACK): nonPackedArray[i] = recolTarget5.r8
			
			if(nonPackedArrayDupe[i] == recolKeyShade6.x 
			&& nonPackedArrayDupe[i+1] == recolKeyShade6.y
			&& nonPackedArrayDupe[i+2] == recolKeyShade6.z
			&& recolTarget6 != Color.BLACK): nonPackedArray[i] = recolTarget6.r8
			
			if(nonPackedArrayDupe[i] == recolKeyShade7.x 
			&& nonPackedArrayDupe[i+1] == recolKeyShade7.y
			&& nonPackedArrayDupe[i+2] == recolKeyShade7.z
			&& recolTarget7 != Color.BLACK): nonPackedArray[i] = recolTarget7.r8
			
			if(nonPackedArrayDupe[i] == recolKeyShade8.x 
			&& nonPackedArrayDupe[i+1] == recolKeyShade8.y
			&& nonPackedArrayDupe[i+2] == recolKeyShade8.z
			&& recolTarget8 != Color.BLACK): nonPackedArray[i] = recolTarget8.r8
			
			if(nonPackedArrayDupe[i] == recolKeyShade9.x 
			&& nonPackedArrayDupe[i+1] == recolKeyShade9.y
			&& nonPackedArrayDupe[i+2] == recolKeyShade9.z
			&& recolTarget9 != Color.BLACK): nonPackedArray[i] = recolTarget9.r8
			
		if(quadSet == 2):
			if(nonPackedArrayDupe[i-1] == recolKeyShade1.x
			&& nonPackedArrayDupe[i] == recolKeyShade1.y
			&& nonPackedArrayDupe[i+1] == recolKeyShade1.z
			&& recolTarget1 != Color.BLACK): nonPackedArray[i] = recolTarget1.g8
			
			if(nonPackedArrayDupe[i-1] == recolKeyShade2.x
			&& nonPackedArrayDupe[i] == recolKeyShade2.y
			&& nonPackedArrayDupe[i+1] == recolKeyShade2.z
			&& recolTarget2 != Color.BLACK): nonPackedArray[i] = recolTarget2.g8
			
			if(nonPackedArrayDupe[i-1] == recolKeyShade3.x
			&& nonPackedArrayDupe[i] == recolKeyShade3.y
			&& nonPackedArrayDupe[i+1] == recolKeyShade3.z
			&& recolTarget3 != Color.BLACK): nonPackedArray[i] = recolTarget3.g8
			
			if(nonPackedArrayDupe[i-1] == recolKeyShade4.x
			&& nonPackedArrayDupe[i] == recolKeyShade4.y
			&& nonPackedArrayDupe[i+1] == recolKeyShade4.z
			&& recolTarget4 != Color.BLACK): nonPackedArray[i] = recolTarget4.g8
			
			if(nonPackedArrayDupe[i-1] == recolKeyShade5.x
			&& nonPackedArrayDupe[i] == recolKeyShade5.y
			&& nonPackedArrayDupe[i+1] == recolKeyShade5.z
			&& recolTarget5 != Color.BLACK): nonPackedArray[i] = recolTarget5.g8
			
			if(nonPackedArrayDupe[i-1] == recolKeyShade6.x
			&& nonPackedArrayDupe[i] == recolKeyShade6.y
			&& nonPackedArrayDupe[i+1] == recolKeyShade6.z
			&& recolTarget6 != Color.BLACK): nonPackedArray[i] = recolTarget6.g8
			
			if(nonPackedArrayDupe[i-1] == recolKeyShade7.x
			&& nonPackedArrayDupe[i] == recolKeyShade7.y
			&& nonPackedArrayDupe[i+1] == recolKeyShade7.z
			&& recolTarget7 != Color.BLACK): nonPackedArray[i] = recolTarget7.g8
			
			if(nonPackedArrayDupe[i-1] == recolKeyShade8.x
			&& nonPackedArrayDupe[i] == recolKeyShade8.y
			&& nonPackedArrayDupe[i+1] == recolKeyShade8.z
			&& recolTarget8 != Color.BLACK): nonPackedArray[i] = recolTarget8.g8
			
			if(nonPackedArrayDupe[i-1] == recolKeyShade9.x
			&& nonPackedArrayDupe[i] == recolKeyShade9.y
			&& nonPackedArrayDupe[i+1] == recolKeyShade9.z
			&& recolTarget9 != Color.BLACK): nonPackedArray[i] = recolTarget9.g8
			
		if(quadSet == 3):
			if(nonPackedArrayDupe[i-2] == recolKeyShade1.x
			&& nonPackedArrayDupe[i-1] == recolKeyShade1.y
			&& nonPackedArrayDupe[i] == recolKeyShade1.z
			&& recolTarget1 != Color.BLACK): nonPackedArray[i] = recolTarget1.b8
			
			if(nonPackedArrayDupe[i-2] == recolKeyShade2.x
			&& nonPackedArrayDupe[i-1] == recolKeyShade2.y
			&& nonPackedArrayDupe[i] == recolKeyShade2.z
			&& recolTarget2 != Color.BLACK): nonPackedArray[i] = recolTarget2.b8
			
			if(nonPackedArrayDupe[i-2] == recolKeyShade3.x
			&& nonPackedArrayDupe[i-1] == recolKeyShade3.y
			&& nonPackedArrayDupe[i] == recolKeyShade3.z
			&& recolTarget3 != Color.BLACK): nonPackedArray[i] = recolTarget3.b8
			
			if(nonPackedArrayDupe[i-2] == recolKeyShade4.x
			&& nonPackedArrayDupe[i-1] == recolKeyShade4.y
			&& nonPackedArrayDupe[i] == recolKeyShade4.z
			&& recolTarget4 != Color.BLACK): nonPackedArray[i] = recolTarget4.b8
			
			if(nonPackedArrayDupe[i-2] == recolKeyShade5.x
			&& nonPackedArrayDupe[i-1] == recolKeyShade5.y
			&& nonPackedArrayDupe[i] == recolKeyShade5.z
			&& recolTarget5 != Color.BLACK): nonPackedArray[i] = recolTarget5.b8
			
			if(nonPackedArrayDupe[i-2] == recolKeyShade6.x
			&& nonPackedArrayDupe[i-1] == recolKeyShade6.y
			&& nonPackedArrayDupe[i] == recolKeyShade6.z
			&& recolTarget6 != Color.BLACK): nonPackedArray[i] = recolTarget6.b8
			
			if(nonPackedArrayDupe[i-2] == recolKeyShade7.x
			&& nonPackedArrayDupe[i-1] == recolKeyShade7.y
			&& nonPackedArrayDupe[i] == recolKeyShade7.z
			&& recolTarget7 != Color.BLACK): nonPackedArray[i] = recolTarget7.b8
			
			if(nonPackedArrayDupe[i-2] == recolKeyShade8.x
			&& nonPackedArrayDupe[i-1] == recolKeyShade8.y
			&& nonPackedArrayDupe[i] == recolKeyShade8.z
			&& recolTarget8 != Color.BLACK): nonPackedArray[i] = recolTarget8.b8
			
			if(nonPackedArrayDupe[i-2] == recolKeyShade9.x
			&& nonPackedArrayDupe[i-1] == recolKeyShade9.y
			&& nonPackedArrayDupe[i] == recolKeyShade9.z
			&& recolTarget9 != Color.BLACK): nonPackedArray[i] = recolTarget9.b8

		if(quadSet == 4):
			quadSet = 0

	recolTarget1 = Color.BLACK
	recolTarget2 = Color.BLACK
	recolTarget3 = Color.BLACK
	recolTarget4 = Color.BLACK
	recolTarget5 = Color.BLACK
	recolTarget6 = Color.BLACK
	recolTarget7 = Color.BLACK
	recolTarget8 = Color.BLACK
	recolTarget9 = Color.BLACK
	
	var repackedArray: PackedByteArray = PackedByteArray(nonPackedArray)

	var img = Image.create_from_data(loadedImage.data.width, 
	loadedImage.data.height, false, Image.FORMAT_RGBA8, repackedArray)
	
	var newTexNode = TextureRect.new()
	newTexNode.texture = ImageTexture.create_from_image(img)
	newTexNode.expand_mode = TextureRect.EXPAND_KEEP_SIZE
	newTexNode.stretch_mode = TextureRect.STRETCH_KEEP
	respritedIMGContainer.add_child(newTexNode)

	currentImgExportNum += 1

	var fileNameThenExtensionArray = imgName.split(".", true)
	var imgNameWithoutExtension = fileNameThenExtensionArray[0]

	var filename: String = imgNameWithoutExtension + str(currentImgExportNum) + ".webp"
	var result_webp = img.save_webp(folderPathString +"/"+ filename,false)

	#if( result_webp == OK): print("image ", filename, " exported OK at: ", folderPathString )
	#else: print("export failed")
