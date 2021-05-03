extends Node2D

# if your have any questions just DM me: https://www.reddit.com/user/RonvidvS

# rules:
	# Random 50% chance, give up
	# If the neighbour cell is already occupied, give up
	# If the neighbour cell itself has more than one filled neighbour, give up.
	# If we already have enough rooms, give up
		# otherwise mark the grid positon and place a room there

	# the Bossroom only has 1 neighbour and is the room farthest to the start room
	# The Itemroom only has 1 neighbour and is the room nearest to the start room

	# check out this website for a gerneral understanding: https://www.boristhebrave.com/2020/09/12/dungeon-generation-in-binding-of-isaac/

var grid_sizex = 7 # max rooms horizontal -> really buggy right now, do not change (I will try to fix this soon)
var grid_sizey = 7 # max rooms vertical -> really buggy right now, do not change (I will try to fix this soon)

var grid = [] # grid Array -> created in the create_grid() function

var neighbour_rooms = [Vector2(0,1),Vector2(0,-1),Vector2(1,0),Vector2(-1,0)] # grid coordinates for the neighbour rooms

var placed_rooms = [] # Array2D that stores where are rooms placed in the grid 

var room_size = Vector2(320,192) # size of the individual room / needs to be as big as your rooms -> in this case 320x192 pixel see: "res://Rooms/NormalRooms/1.tscn"

var room_ID = [] # saves the IDs of the placed rooms / -> we need that later 

var start_room_pos = Vector2(3,3) # grid position of the first room
var rooms = 0 # current count of rooms
var min_rooms = 7 # min placed rooms
var max_rooms = 9 # max placed rooms

var first_room # stores the ID of the first room 

onready var room = preload("res://Rooms/Room.tscn") # preloads the room scene 


func _ready():
	create_grid()
	
func create_grid(): #creates an Array2D which we use as a grid 
	
	for x in range(grid_sizey): # creates 7/(grid_sizey) arrays and appends them to the grid array
		grid.append([])  # -> note that we do this for the vertical grid si first, because in 2D arrays x is the vertical axis and y is the horizontal axis
		for y in range(grid_sizex): # creates 7/(grid_sizex) Vector2Ds and appends them to the grid array
			grid[x].append(Vector2(y,x)) # now the grid has 7/grid_sizey with 7/grid_sizex Vector2Ds each -> top-left: Vector2D(0,0) to bottom-right: Vector2D(6,6)
										# -> note that the first value in an array has the index 0, so the maximum x/y index in the array is the grid size -1
	for x in range(grid_sizey): # now we append false to the placed_rooms array for every grid position in our grid array 
		placed_rooms.append([false]) 
		for y in range(grid_sizex):
			placed_rooms[x].append(false) # -> this array will store the information about where a rooms is placed 
	
	startroom() # -> now we start with creating our first room
	
func startroom(): # place the first room to the start_room_pos 
	rooms += 1 # room counter + 1
	var new_room = room.instance()
	new_room.global_position = Vector2(grid[start_room_pos.x][start_room_pos.y].x * room_size.x, grid[start_room_pos.x][start_room_pos.y].y * room_size.y)
	new_room.startroom = true # this tells the room that it is the startroom
	add_child(new_room)
	first_room = new_room # saves the ID of the startroom -> we need that later
	room_ID.append(new_room) # appends the room (ID) to an array -> we need that later
	placed_rooms[start_room_pos.x][start_room_pos.y] = true # this tells the array that there is a room at the start_room_pos
	check_neighbours() 
	
	
	
func check_neighbours(): # this function checks if the rules are fulfilled and calls the place rooms function if so
	
	for y in grid: # loops through the grid array (y)
		for x in y: # loops through the arrays inside the grid array (x) -> we need to loop 2 times here because the grid array is an array2D
			var curneigh = 0 # we need this variable later
			var neighneigh = 0 # we need this variable later
			for neighbours in neighbour_rooms: # loops through the neighbour_rooms array
				if x.x + neighbours.x in range(grid_sizex) && x.y + neighbours.y in range(grid_sizey): # we need this to make sure the neighbour is indide the grid
					if placed_rooms[x.x + neighbours.x][x.y + neighbours.y] == true: # if the current grid_position has a neighbour
						curneigh += 1                                                # -> counts neighbours
						neighneigh += check_neighbours_neighbour(Vector2(x.x + neighbours.x,x.y + neighbours.y)) # this counts the neighbours of the neighbour 
						
			if curneigh != 0 && curneigh < 3 && placed_rooms[x.x][x.y] == false && neighneigh < 2: # now we check if all of our rules(->see above) were fulfilled 
				# -> less than 3 neighbours / there is no room at this position / the neighbour has less than 2 neighbours
				place_rooms(x) # -> if so place a room at the grid position * room_size / x = the grid positon of room that should be placed
				
	if rooms < min_rooms: # this loops the function until rooms < min_rooms
		check_neighbours()
		
	else: # if there are enough rooms these functions are called
		select_endroom()
		select_itemroom()
		set_walls()

func place_rooms(cell): # place the rooms / cell contains the information about the grid postion of the room
	if rooms < max_rooms: # only executes the code if there are less rooms than max_rooms
		randomize()
		if randi()%2 == 1: # picks 0 or 1 and only places the room if it has picked 1 -> because of the rules(-> see above) 50% chance to give up
			var new_room = room.instance()
			
			new_room.global_position = Vector2(grid[cell.x][cell.y].x * room_size.x, grid[cell.x][cell.y].y * room_size.y) # we need to multiply the position in the grid with the 
			room_ID.append(new_room)
			new_room.text = String(rooms) # only sets the text for the visualization
			
			add_child(new_room)
			placed_rooms[cell.x][cell.y] = true
			rooms += 1
			
			# -> the code above instances a room, sets the positon, adds it to the rooms_ID array, tell the placed_rooms array that there is a room now and adds the room as a child to the world
			
func check_neighbours_neighbour(cell): # just checks if the cell has a neighbour / cell contains information about the grid postion of the room
	var neighb = 0
	if placed_rooms[cell.x][cell.y] == true:
		neighb += 1
	return neighb # returns the count of neighbours 
			
func select_endroom():
	var last_room
	var dis = 0 
	for i in room_ID: # this loops through every room placed before
		var count = 0
		for x in neighbour_rooms: # check if the room(i) has neighbours
			var neigh = Vector2(i.global_position.x / room_size.x, i.global_position.y / room_size.y) + x
			if neigh.x in range(grid_sizex) && neigh.y in range(grid_sizey): # check if the neighbour is in the grid
				if placed_rooms[neigh.y][neigh.x] == true:
					count += 1
		if first_room.global_position.distance_to(i.global_position) > dis && count < 2: # check if the distance of the room and the start room is > the saved distance and the room only has 1 neighbour
			
			dis = first_room.global_position.distance_to(i.global_position) # saves the distance from the start room to the current room
			last_room = i
	
	last_room.last_room() # calls the last_room() function in the selected room
	
func set_walls():
	for room in room_ID:
		room.set_walls()

func _input(event):
	if Input.is_action_just_pressed("ui_accept"):
		get_tree().reload_current_scene()
	
func select_itemroom():
	var has_itemroom = false
	for i in room_ID:
		var count = 0
		for x in neighbour_rooms:
			var neigh = Vector2(i.global_position.x / room_size.x, i.global_position.y / room_size.y) + x
			if neigh.x in range(grid_sizex) && neigh.y in range(grid_sizey):
				if placed_rooms[neigh.y][neigh.x] == true:
					count += 1
		if count <2 && has_itemroom == false && i.bossroom == false && i.startroom == false:
			has_itemroom = true
			i.item_room()
