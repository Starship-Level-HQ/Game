Kaban = {
  new = function() 
    local self = {}
    self.shape = love.physics.newRectangleShape(60, 58)              --размер коллайдера
    self.width = 50
    self.height = 60
    self.spriteSheet = love.graphics.newImage('res/sprites/kaban.png')
    self.grid = anim8.newGrid(24, 24, self.spriteSheet:getWidth(), self.spriteSheet:getHeight())
    self.animations = {}
    self.animations.down = anim8.newAnimation(self.grid('1-4', 1), 0.2)
    self.animations.up = anim8.newAnimation(self.grid('1-4', 4), 0.2)
    self.animations.right = anim8.newAnimation(self.grid('1-4', 3), 0.2)
    self.animations.left = anim8.newAnimation(self.grid('1-4', 2), 0.2)
    return self
  end
}