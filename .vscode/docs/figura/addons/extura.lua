---Sets the player velocity.  
---***
---**Exturaddon:**  
---Requires `host.isExturaCheats()` to be true
---***
---**NOTE:** This feature requires one of the following plugins:  
---**Extura**, **Exturaddon** or **Goofy Plugin**
---@overload fun(self,vel: Vector3)
---@param x number
---@param y number
---@param z number
function host:setVelocity(x,y,z)
end

---Sets the player position.  
---***
---**Exturaddon:**  
---Requires `host.isExturaCheats()` to be true
---***
---**NOTE:** This feature requires one of the following plugins:  
---**Extura**, **Exturaddon** or **Goofy Plugin**
---@overload fun(self,pos: Vector3)
---@param x number
---@param y number
---@param z number
function host:setPos(x,y,z)
end

---Sets if the player recives air resistance or floor friction.  
---***
---**Exturaddon:**  
---Requires `host.isExturaCheats()` to be true
---***
---**NOTE:** This feature requires one of the following plugins:  
---**Extura**, **Exturaddon** or **Goofy Plugin**
---@param drag boolean
function host:setDrag(drag)
end