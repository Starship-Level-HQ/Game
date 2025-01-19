PlayerUpdate = {
    new = function(self)
        function self:update(dt)
            local isMoving = false
            local speed = self.defaultSpeed
            if self.isDashing then
                speed = speed + self.dashSpeed
            end

            if love.keyboard.isDown(userConfig.leftButton) then
                xv, yv = self.body:getLinearVelocity()
                self.body:setLinearVelocity(-speed, yv)
                self.anim = self.animations.left
                self.direction = "l"
                self.serverDirectionX = "l"
                isMoving = true
            elseif love.keyboard.isDown(userConfig.rightButton) then
                xv, yv = self.body:getLinearVelocity()
                self.body:setLinearVelocity(speed, yv)
                self.anim = self.animations.right
                self.direction = "r"
                self.serverDirectionX = "r"
                isMoving = true
            else
                xv, yv = self.body:getLinearVelocity()
                self.body:setLinearVelocity(0, yv)
                self.serverDirectionX = ""
            end

            if love.keyboard.isDown(userConfig.upButton) then
                xv, yv = self.body:getLinearVelocity()
                self.body:setLinearVelocity(xv, -speed)
                self.anim = self.animations.up
                self.direction = "u"
                self.serverDirectionY = "u"
                isMoving = true
            elseif love.keyboard.isDown(userConfig.downButton) then
                xv, yv = self.body:getLinearVelocity()
                self.body:setLinearVelocity(xv, speed)
                self.anim = self.animations.down
                self.direction = "d"
                self.serverDirectionY = "d"
                isMoving = true
            else
                xv, yv = self.body:getLinearVelocity()
                self.body:setLinearVelocity(xv, 0)
                self.serverDirectionY = ""
            end

            xv, yv = self.body:getLinearVelocity()
            self.direction = physics.calculateDirection(xv, yv, self.direction) -- 45'

            if isMoving == false then
                if self.direction == "d" then
                    self.anim = self.animations.sDown
                elseif self.direction == "u" then
                    self.anim = self.animations.sUp
                elseif self.direction == "r" then
                    self.anim = self.animations.sRight
                else
                    self.anim = self.animations.sLeft
                end
            end

            if love.keyboard.isDown("lshift") and not self.isDashing and self.dashCooldownLeft <= 0 then
                self.isDashing = true
                self.dashTimeLeft = self.dashDuration
                self.fixture:setCategory(cat.DASHING_PLAYER)
                --print(self.nearestItem)
            end

            if self.health == 0 then
                self.health = 1
            end
            self.updateEffects(dt)
            self:updateDash(dt)
            self.anim:update(dt)
            self:updateShots(dt)
            self:updateSlash(dt)
            self:updateInventary()
        end

        function self.updateEffects(dt) -- {name, ..param}
            local effectHandlers = {
                Здоровье = function(param)
                    self.health = self.health + param[2]
                    return nil
                end,

                Регенерация = function(param)
                    if param[3] > 0 then
                        self.health = self.health + param[2] * dt
                        return { param[1], param[2], param[3] - dt }
                    else
                        return nil
                    end
                end,

                default = function()
                    print("Неизвестный эффект")
                    return nil
                end
            }

            for i, effect in ipairs(self.effects) do
                local effectName = effect[1]

                local handler = effectHandlers[effectName] or effectHandlers.default
                local updatedParams = handler(effect)

                if updatedParams then
                    self.effects[i] = updatedParams
                else
                    table.remove(self.effects, i)
                    i = i - 1
                end
            end
        end

        function self:updateInventary()
            if (self.inventoryIsOpen) then self.inventoryGui:update() end
        end

        function self:updateShots(dt)
            local remShot = {}

            -- update the shots
            for i, s in ipairs(self.shots) do
                s.update(remShot, i, dt)
            end

            for i, _ in ipairs(remShot) do
                table.remove(self.shots, i)
            end
        end

        function self:updateSlash(dt)
            local remShot = {}

            -- update the shots
            for i, s in ipairs(self.slashes) do
                s.update(remShot, i, dt)
            end

            for i, _ in ipairs(remShot) do
                table.remove(self.slashes, i)
            end
        end

        function self:updateDash(dt)
            --След
            if self.dashTimeLeft > 0 then
                self.trailTimer = self.trailTimer - dt
                if self.trailTimer <= 0 then
                    table.insert(self.trail,
                        {
                            x = self.body:getX(),
                            y = self.body:getY(),
                            anim = self.anim,
                            alpha = 0.3,
                            lifetime = self
                                .trailDuration
                        })
                    self.trailTimer = self.trailFrequency
                end
            end
            -- Обновление следов во время рывка
            for i, t in ipairs(self.trail) do
                t.lifetime = t.lifetime - dt
                if t.lifetime <= 0 then
                    table.remove(self.trail, i)
                end
            end
            if self.isDashing then
                self.dashTimeLeft = self.dashTimeLeft - dt
                if self.dashTimeLeft <= 0 then
                    self.isDashing = false
                    self.dashCooldownLeft = self.dashCooldown
                end
            elseif self.dashCooldownLeft > 0 then
                self.dashCooldownLeft = self.dashCooldownLeft - dt
            end
            if not self.isDashing then
                self.fixture:setCategory(cat.PLAYER)
            end
        end

        function self:updateRemotePlayer(dt, remotePlayerData)
            self.health = remotePlayerData.health
            local speed = self.defaultSpeed

            -- Проверяем состояние dash на основе данных от сервера
            if remotePlayerData.isDashing then
                speed = speed + self.dashSpeed
                self.isDashing = true
            else
                self.isDashing = false
            end

            if remotePlayerData.directionX == "l" then
                self.body:setLinearVelocity(-speed, remotePlayerData.yv)
                self.anim = self.animations.left
                self.direction = "l"
            elseif remotePlayerData.directionX == "r" then
                self.body:setLinearVelocity(speed, remotePlayerData.yv)
                self.anim = self.animations.right
                self.direction = "r"
            else
                self.body:setLinearVelocity(0, remotePlayerData.yv)
            end

            if remotePlayerData.directionY == "u" then
                self.body:setLinearVelocity(remotePlayerData.xv, -speed)
                self.anim = self.animations.up
                self.direction = "u"
            elseif remotePlayerData.directionY == "d" then
                self.body:setLinearVelocity(remotePlayerData.xv, speed)
                self.anim = self.animations.down
                self.direction = "d"
            else
                self.body:setLinearVelocity(remotePlayerData.xv, 0)
            end

            if (remotePlayerData.directionX == "" and remotePlayerData.directionY == "") then
                self.anim:gotoFrame(2) -- не движется
            end

            self.direction = physics.calculateDirection(remotePlayerData.xv, remotePlayerData.yv, self.direction)

            -- Обновляем dash-статус и анимацию
            if self.isDashing then
                self.dashTimeLeft = self.dashDuration
                self.fixture:setCategory(cat.DASHING_PLAYER)
            else
                self.fixture:setCategory(cat.PLAYER)
            end

            self:updateDash(dt)
            self.anim:update(dt)
            self:updateShots(dt)
            self:updateSlash(dt)
            self:updateInventary()
        end
    end
}
