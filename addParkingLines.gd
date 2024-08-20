extends CSGBox3D


# Called when the node enters the scene tree for the first time.
func _ready():
	var rng = RandomNumberGenerator.new();
	
	var width = 50;
	var height = 50;
	
	var data = PackedByteArray();
	for x in range(width):
		for y in range(height):
			data.push_back(255)
			data.push_back(0)
			data.push_back(rng.randi_range(0, 255))
	
	var image = Image.new();
	image.set_data(width, height, false, Image.FORMAT_RGB8, data)
	
	var texture = ImageTexture.create_from_image(image);
	
	var mat = StandardMaterial3D.new();
	mat.albedo_texture = texture;
	
	material = mat;
	
	print("Set albedo texture")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
