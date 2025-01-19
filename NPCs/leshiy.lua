Leshiy = {
  new = function() 
    local self = {}
    self.shape = love.physics.newRectangleShape(66, 175)              --размер коллайдера
    self.width = 68
    self.height = 130
    self.spriteSheet = love.graphics.newImage('res/sprites/leshiy2.png')
    self.grid = anim8.newGrid(43, 82, self.spriteSheet:getWidth(), self.spriteSheet:getHeight())
    self.animations = {}
    self.animations.down = anim8.newAnimation(self.grid('1-4', 1), 0.2)
    self.animations.up = anim8.newAnimation(self.grid('1-4', 2), 0.2)
    self.animations.right = anim8.newAnimation(self.grid('1-4', 1), 0.2)
    self.animations.left = anim8.newAnimation(self.grid('1-4', 1), 0.2)
    self.zoom = 3
    
    self.deadSpriteSheet = love.graphics.newImage('res/sprites/leshiy-dead.png')
    self.deadGrid = anim8.newGrid(46, 82, self.deadSpriteSheet:getWidth(), self.deadSpriteSheet:getHeight())
    if not userConfig.blood then
      self.deadAnimations = anim8.newAnimation(self.deadGrid('1-1', 1), 1)
    else
      self.deadAnimations = anim8.newAnimation(self.deadGrid('2-2', 1), 1)
    end
    return self
  end
}