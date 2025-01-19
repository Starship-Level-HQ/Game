Zombee = {
  new = function() 
    local self = {}
    self.shape = love.physics.newRectangleShape(24, 60)              --размер коллайдера
    self.width = 24
    self.height = 30
    self.spriteSheet = love.graphics.newImage('res/sprites/enemy-sheet.png')
    self.grid = anim8.newGrid(12, 18, self.spriteSheet:getWidth(), self.spriteSheet:getHeight())
    self.animations = {}
    self.animations.down = anim8.newAnimation(self.grid('1-4', 1), 0.2)
    self.animations.up = anim8.newAnimation(self.grid('1-4', 4), 0.2)
    self.animations.right = anim8.newAnimation(self.grid('1-4', 3), 0.2)
    self.animations.left = anim8.newAnimation(self.grid('1-4', 2), 0.2)
    self.canShoot = true
    
    self.deadSpriteSheet = love.graphics.newImage('res/sprites/enemy-dead.png')
    self.deadGrid = anim8.newGrid(12, 18, self.deadSpriteSheet:getWidth(), self.deadSpriteSheet:getHeight())
    if userConfig.blood then
      self.deadAnimations = anim8.newAnimation(self.deadGrid('1-1', 1), 1)
    else
      self.deadAnimations = anim8.newAnimation(self.deadGrid('2-2', 1), 1)
    end
    return self
  end
}