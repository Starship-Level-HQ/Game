PlayerCollisions = {
  new = function(self)

    function self:collisionWithShot(damage)
      self.health = self.health - damage
    end

    function self:collisionWithEnemy(fixture_b, damage)
      self.health = self.health - damage
      xi, yi = fixture_b:getBody():getLinearVelocity()
      self.body:applyLinearImpulse(xi * 55, yi * 55) --отскок игрока при получении урона, пока слишком резкий, если получится сделать плавным - оставим
    end

  end
}