Tween={}local function a(b)if b.target~=nil then Daneel.Debug.StackTrace.BeginFunction("GetTweenerProperty",b)local c=nil;c=b.target[b.property]if c==nil then local d="Get"..string.ucfirst(b.property)if b.target[d]~=nil then c=b.target[d](b.target)end end;Daneel.Debug.StackTrace.EndFunction()return c end end;local function e(b,c)if b.target~=nil then Daneel.Debug.StackTrace.BeginFunction("SetTweenerProperty",b,c)if b.valueType=="string"then if type(c)=="number"and c>=#b.stringValue+1 then local f=b.startStringValue..b.endStringValue:sub(1,c)if f~=b.stringValue then b.stringValue=f;c=f else return end else return end end;if b.target[b.property]==nil then local d="Set"..string.ucfirst(b.property)if b.target[d]~=nil then b.target[d](b.target,b.property)end else b.target[b.property]=c end;Daneel.Debug.StackTrace.EndFunction()end end;Tween.Tweener={tweeners={}}Tween.Tweener.__index=Tween.Tweener;setmetatable(Tween.Tweener,{__call=function(g,...)return g.New(...)end})function Tween.Tweener.__tostring(b)return"Tweener: "..b.id end;function Tween.Tweener.New(h,i,j,k,l,m)Daneel.Debug.StackTrace.BeginFunction("Tween.Tweener.New",h,i,j,k,m)local n="Tween.Tweener.New(target, property, endValue, duration[, params]) : "local b=table.copy(Tween.Config.tweener)setmetatable(b,Tween.Tweener)b.id=Daneel.Utilities.GetId()local o=type(h)local p=nil;if o=="table"then p=getmetatable(h)end;if o=="number"or o=="string"or p==Vector2 or p==Vector3 then m=l;l=k;k=j;j=i;local q=h;n="Tween.Tweener.New(startValue, endValue, duration[, onCompleteCallback, params]) : "Daneel.Debug.CheckArgType(k,"duration","number",n)if type(l)=="table"then m=l;l=nil end;Daneel.Debug.CheckOptionalArgType(l,"onCompleteCallback","function",n)Daneel.Debug.CheckOptionalArgType(m,"params","table",n)b.startValue=q;b.endValue=j;b.duration=k;if l~=nil then b.OnComplete=l end;if m~=nil then b:Set(m)end elseif i==nil then Daneel.Debug.CheckArgType(h,"params","table",n)n="Tween.Tweener.New(params) : "b:Set(h)else Daneel.Debug.CheckArgType(h,"target","table",n)Daneel.Debug.CheckArgType(i,"property","string",n)Daneel.Debug.CheckArgType(k,"duration","number",n)if type(l)=="table"then m=l;l=nil end;Daneel.Debug.CheckOptionalArgType(l,"onCompleteCallback","function",n)Daneel.Debug.CheckOptionalArgType(m,"params","table",n)b.target=h;b.property=i;b.endValue=j;b.duration=k;if l~=nil then b.OnComplete=l end;if m~=nil then b:Set(m)end end;if b.endValue==nil then error("Tween.Tweener.New(): 'endValue' property is nil for tweener: "..tostring(b))end;if b.startValue==nil then b.startValue=a(b)end;if b.target~=nil then b.gameObject=b.target.gameObject end;b.valueType=Daneel.Debug.GetType(b.startValue)if b.valueType=="string"then b.startStringValue=b.startValue;b.stringValue=b.startStringValue;b.endStringValue=b.endValue;b.startValue=1;b.endValue=#b.endStringValue end;Tween.Tweener.tweeners[b.id]=b;Daneel.Debug.StackTrace.EndFunction()return b end;function Tween.Tweener.Set(b,m)Daneel.Debug.StackTrace.BeginFunction("Tween.Tweener.Set",b,m)local n="Tween.Tweener.Set(tweener, params) : "Daneel.Debug.CheckArgType(b,"tweener","Tween.Tweener",n)for r,c in pairs(m)do b[r]=c end;Daneel.Debug.StackTrace.EndFunction()return b end;function Tween.Tweener.Play(b)if b.isEnabled==false then return end;Daneel.Debug.StackTrace.BeginFunction("Tween.Tweener.Play",b)local n="Tween.Tweener.Play(tweener) : "Daneel.Debug.CheckArgType(b,"tweener","Tween.Tweener",n)b.isPaused=false;Daneel.Event.Fire(b,"OnPlay",b)Daneel.Debug.StackTrace.EndFunction()end;function Tween.Tweener.Pause(b)if b.isEnabled==false then return end;Daneel.Debug.StackTrace.BeginFunction("Tween.Tweener.Pause",b)local n="Tween.Tweener.Pause(tweener) : "Daneel.Debug.CheckArgType(b,"tweener","Tween.Tweener",n)b.isPaused=true;Daneel.Event.Fire(b,"OnPause",b)Daneel.Debug.StackTrace.EndFunction()end;function Tween.Tweener.Restart(b)if b.isEnabled==false then return end;Daneel.Debug.StackTrace.BeginFunction("Tween.Tweener.Restart",b)local n="Tween.Tweener.Restart(tweener) : "Daneel.Debug.CheckArgType(b,"tweener","Tween.Tweener",n)b.elapsed=0;b.fullElapsed=0;b.elapsedDelay=0;b.completedLoops=0;b.isCompleted=false;b.hasStarted=false;local q=b.startValue;if b.loopType=="yoyo"and b.completedLoops%2~=0 then q=b.endValue end;if b.target~=nil then e(b,q)end;b.value=q;Daneel.Debug.StackTrace.EndFunction()end;function Tween.Tweener.Complete(b)if b.isEnabled==false or b.loops==-1 then return end;Daneel.Debug.StackTrace.BeginFunction("Tween.Tweener.Complete",b)local n="Tween.Tweener.Complete( tweener ) : "Daneel.Debug.CheckArgType(b,"tweener","Tween.Tweener",n)b.isCompleted=true;local j=b.endValue;if b.loopType=="yoyo"then if b.loops%2==0 and b.completedLoops%2==0 then j=b.startValue elseif b.loops%2~=0 and b.completedLoops%2~=0 then j=b.startValue end end;if b.target~=nil then e(b,j)end;b.value=j;Daneel.Event.Fire(b,"OnComplete",b)if b.destroyOnComplete then b:Destroy()end;Daneel.Debug.StackTrace.EndFunction()end;local function s(t)return t.isDestroyed==true or t.inner==nil end;function Tween.Tweener.IsTargetDestroyed(b)if b.target~=nil then if b.target.isDestroyed then return true end;if b.target.gameObject~=nil and s(b.target.gameObject)then return true end end;if b.gameObject~=nil and s(b.gameObject)then return true end;return false end;function Tween.Tweener.Destroy(b)Daneel.Debug.StackTrace.BeginFunction("Tween.Tweener.Destroy",b)local n="Tween.Tweener.Destroy( tweener ) : "Daneel.Debug.CheckArgType(b,"tweener","Tween.Tweener",n)b.isEnabled=false;b.isPaused=true;b.target=nil;b.duration=0;Tween.Tweener.tweeners[b.id]=nil;CraftStudio.Destroy(b)Daneel.Debug.StackTrace.EndFunction()end;function Tween.Tweener.Update(b,u)if b.isEnabled==false then return end;Daneel.Debug.StackTrace.BeginFunction("Tween.Tweener.Update",b,u)local n="Tween.Tweener.Update(tweener[, deltaDuration]) : "Daneel.Debug.CheckArgType(b,"tweener","Tween.Tweener",n)Daneel.Debug.CheckArgType(u,"deltaDuration","number",n)if Tween.Ease[b.easeType]==nil then if Daneel.Config.debug.enableDebug then print("Tween.Tweener.Update() : Easing '"..tostring(b.easeType).."' for tweener ID '"..tween.id.."' does not exists. Setting it back for the default easing '"..Tween.Config.tweener.easeType.."'.")end;b.easeType=Tween.Config.tweener.easeType end;if u~=nil then b.elapsed=b.elapsed+u;b.fullElapsed=b.fullElapsed+u end;local c=nil;if b.elapsed>b.duration then b.isCompleted=true;b.elapsed=b.duration;if b.isRelative==true then c=b.startValue+b.endValue else c=b.endValue end else if b.valueType=="Vector3"then c=Vector3:New(Tween.Ease[b.easeType](b.elapsed,b.startValue.x,b.diffValue.x,b.duration),Tween.Ease[b.easeType](b.elapsed,b.startValue.y,b.diffValue.y,b.duration),Tween.Ease[b.easeType](b.elapsed,b.startValue.z,b.diffValue.z,b.duration))elseif b.valueType=="Vector2"then c=Vector2.New(Tween.Ease[b.easeType](b.elapsed,b.startValue.x,b.diffValue.x,b.duration),Tween.Ease[b.easeType](b.elapsed,b.startValue.y,b.diffValue.y,b.duration))else c=Tween.Ease[b.easeType](b.elapsed,b.startValue,b.diffValue,b.duration)end end;if b.target~=nil then e(b,c)end;b.value=c;Daneel.Event.Fire(b,"OnUpdate",b)Daneel.Debug.StackTrace.EndFunction()end;Tween.Timer={}Tween.Timer.__index=Tween.Tweener;setmetatable(Tween.Timer,{__call=function(g,...)return g.New(...)end})function Tween.Timer.New(k,v,w,m)Daneel.Debug.StackTrace.BeginFunction("Tween.Timer.New",k,v,w,m)local n="Tween.Timer.New( duration, callback[, isInfiniteLoop, params] ) : "if type(w)=="table"then m=w;n="Tween.Timer.New( duration, callback[, params] ) : "end;Daneel.Debug.CheckArgType(k,"duration","number",n)Daneel.Debug.CheckArgType(v,"callback",{"function","userdata"},n)Daneel.Debug.CheckOptionalArgType(m,"params","table",n)local b=table.copy(Tween.Config.tweener)setmetatable(b,Tween.Tweener)b.id=Daneel.Utilities.GetId()b.startValue=k;b.endValue=0;b.duration=k;if w==true then b.loops=-1;b.OnLoopComplete=v else b.OnComplete=v end;if m~=nil then b:Set(m)end;Tween.Tweener.tweeners[b.id]=b;Daneel.Debug.StackTrace.EndFunction()return b end;Daneel.modules.Tween=Tween;function Tween.DefaultConfig()local x={tweener={isEnabled=true,isPaused=false,delay=0.0,duration=0.0,durationType="time",startValue=nil,endValue=0.0,loops=0,loopType="simple",easeType="linear",isRelative=false,destroyOnComplete=true,destroyOnSceneLoad=true,updateInterval=1,Id=-1,hasStarted=false,isCompleted=false,elapsed=0,fullElapsed=0,elapsedDelay=0,completedLoops=0,diffValue=0.0,value=0.0,frameCount=0},objects={["Tween.Tweener"]=Tween.Tweener},propertiesByComponentName={transform={"scale","localScale","position","localPosition","eulerAngles","localEulerAngles"},modelRenderer={"opacity"},mapRenderer={"opacity"},textRenderer={"text","opacity"},camera={"fov"}}}return x end;Tween.Config=Tween.DefaultConfig()function Tween.Awake()if Tween.Config.componentNamesByProperty==nil then local y={}for z,A in pairs(Tween.Config.propertiesByComponentName)do for B=1,#A do local i=A[B]y[i]=y[i]or{}table.insert(y[i],z)end end;Tween.Config.componentNamesByProperty=y end;for C,b in pairs(Tween.Tweener.tweeners)do if b.destroyOnSceneLoad then b:Destroy()end end end;function Tween.Update()for C,b in pairs(Tween.Tweener.tweeners)do if b:IsTargetDestroyed()then b:Destroy()end;if b.isEnabled==true and b.isPaused==false and b.isCompleted==false and b.duration>0 then b.frameCount=b.frameCount+1;if b.frameCount%b.updateInterval==0 then local u=Daneel.Time.deltaTime*b.updateInterval;if b.durationType=="realTime"then u=Daneel.Time.realDeltaTime*b.updateInterval elseif b.durationType=="frame"then u=b.updateInterval end;if u>0 then if b.elapsedDelay>=b.delay then if b.hasStarted==false then b.hasStarted=true;if b.startValue==nil then if b.target~=nil then b.startValue=a(b)else error("Tween.Update() : startValue is nil but no target is set for tweener: "..tostring(b))end elseif b.target~=nil then e(b,b.startValue)end;b.value=b.startValue;if b.isRelative==true then b.diffValue=b.endValue else b.diffValue=b.endValue-b.startValue end;Daneel.Event.Fire(b,"OnStart",b)end;b:Update(u)else b.elapsedDelay=b.elapsedDelay+u end;if b.isCompleted==true then b.completedLoops=b.completedLoops+1;if b.loops==-1 or b.completedLoops<b.loops then b.isCompleted=false;b.elapsed=0;if b.loopType:lower()=="yoyo"then local q=b.startValue;if b.isRelative then b.startValue=b.value;b.endValue=-b.endValue;b.diffValue=b.endValue else b.startValue=b.endValue;b.endValue=q;b.diffValue=-b.diffValue end elseif b.target~=nil then e(b,b.startValue)end;b.value=b.startValue;Daneel.Event.Fire(b,"OnLoopComplete",b)else Daneel.Event.Fire(b,"OnComplete",b)if b.destroyOnComplete and b.Destroy~=nil then b:Destroy()end end end end end end end end;local function D(t,i)local E=nil;if Daneel.modules.GUI~=nil and t.hud~=nil and i=="position"or i=="localPosition"then E=t.hud else local F=Tween.Config.componentNamesByProperty[i]if F~=nil then for B=1,#F do E=t[F[B]]if E~=nil then break end end end end;if E==nil then error("Tween: resolveTarget(): Couldn't resolve the target for property '"..i.."' and gameObject: "..tostring(t))end;return E end;function GameObject.Animate(t,i,j,k,l,m)local E=nil;if type(l)=="table"and m==nil then m=l;l=nil end;if m~=nil and m.target~=nil then E=m.target else E=D(t,i)end;return Tween.Tweener.New(E,i,j,k,l,m)end;function GameObject.AnimateAndDestroy(t,i,j,k,m)local E=nil;if m~=nil and m.target~=nil then E=m.target else E=D(t,i)end;return Tween.Tweener.New(E,i,j,k,function()t:Destroy()end,m)end
-- Easing equations
-- From Emmanuel Oga's easing equations : https://github.com/EmmanuelOga/easing

--
-- Adapted from
-- Tweener's easing functions (Penner's Easing Equations)
-- and http://code.google.com/p/tweener/ (jstweener javascript version)
--

--[[
Disclaimer for Robert Penner's Easing Equations license:

TERMS OF USE - EASING EQUATIONS

Open source under the BSD License.

Copyright © 2001 Robert Penner
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
* Neither the name of the author nor the names of contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

-- For all easing functions:
-- t = elapsed time
-- b = begin
-- c = change == ending - beginning
-- d = duration (total time)

local pow = math.pow
local sin = math.sin
local cos = math.cos
local pi = math.pi
local sqrt = math.sqrt
local abs = math.abs
local asin = math.asin

local function linear(t, b, c, d)
  return c * t / d + b
end

local function inQuad(t, b, c, d)
  t = t / d
  return c * pow(t, 2) + b
end

local function outQuad(t, b, c, d)
  t = t / d
  return -c * t * (t - 2) + b
end

local function inOutQuad(t, b, c, d)
  t = t / d * 2
  if t < 1 then
    return c / 2 * pow(t, 2) + b
  else
    return -c / 2 * ((t - 1) * (t - 3) - 1) + b
  end
end

local function outInQuad(t, b, c, d)
  if t < d / 2 then
    return outQuad (t * 2, b, c / 2, d)
  else
    return inQuad((t * 2) - d, b + c / 2, c / 2, d)
  end
end

local function inCubic (t, b, c, d)
  t = t / d
  return c * pow(t, 3) + b
end

local function outCubic(t, b, c, d)
  t = t / d - 1
  return c * (pow(t, 3) + 1) + b
end

local function inOutCubic(t, b, c, d)
  t = t / d * 2
  if t < 1 then
    return c / 2 * t * t * t + b
  else
    t = t - 2
    return c / 2 * (t * t * t + 2) + b
  end
end

local function outInCubic(t, b, c, d)
  if t < d / 2 then
    return outCubic(t * 2, b, c / 2, d)
  else
    return inCubic((t * 2) - d, b + c / 2, c / 2, d)
  end
end

local function inQuart(t, b, c, d)
  t = t / d
  return c * pow(t, 4) + b
end

local function outQuart(t, b, c, d)
  t = t / d - 1
  return -c * (pow(t, 4) - 1) + b
end

local function inOutQuart(t, b, c, d)
  t = t / d * 2
  if t < 1 then
    return c / 2 * pow(t, 4) + b
  else
    t = t - 2
    return -c / 2 * (pow(t, 4) - 2) + b
  end
end

local function outInQuart(t, b, c, d)
  if t < d / 2 then
    return outQuart(t * 2, b, c / 2, d)
  else
    return inQuart((t * 2) - d, b + c / 2, c / 2, d)
  end
end

local function inQuint(t, b, c, d)
  t = t / d
  return c * pow(t, 5) + b
end

local function outQuint(t, b, c, d)
  t = t / d - 1
  return c * (pow(t, 5) + 1) + b
end

local function inOutQuint(t, b, c, d)
  t = t / d * 2
  if t < 1 then
    return c / 2 * pow(t, 5) + b
  else
    t = t - 2
    return c / 2 * (pow(t, 5) + 2) + b
  end
end

local function outInQuint(t, b, c, d)
  if t < d / 2 then
    return outQuint(t * 2, b, c / 2, d)
  else
    return inQuint((t * 2) - d, b + c / 2, c / 2, d)
  end
end

local function inSine(t, b, c, d)
  return -c * cos(t / d * (pi / 2)) + c + b
end

local function outSine(t, b, c, d)
  return c * sin(t / d * (pi / 2)) + b
end

local function inOutSine(t, b, c, d)
  return -c / 2 * (cos(pi * t / d) - 1) + b
end

local function outInSine(t, b, c, d)
  if t < d / 2 then
    return outSine(t * 2, b, c / 2, d)
  else
    return inSine((t * 2) -d, b + c / 2, c / 2, d)
  end
end

local function inExpo(t, b, c, d)
  if t == 0 then
    return b
  else
    return c * pow(2, 10 * (t / d - 1)) + b - c * 0.001
  end
end

local function outExpo(t, b, c, d)
  if t == d then
    return b + c
  else
    return c * 1.001 * (-pow(2, -10 * t / d) + 1) + b
  end
end

local function inOutExpo(t, b, c, d)
  if t == 0 then return b end
  if t == d then return b + c end
  t = t / d * 2
  if t < 1 then
    return c / 2 * pow(2, 10 * (t - 1)) + b - c * 0.0005
  else
    t = t - 1
    return c / 2 * 1.0005 * (-pow(2, -10 * t) + 2) + b
  end
end

local function outInExpo(t, b, c, d)
  if t < d / 2 then
    return outExpo(t * 2, b, c / 2, d)
  else
    return inExpo((t * 2) - d, b + c / 2, c / 2, d)
  end
end

local function inCirc(t, b, c, d)
  t = t / d
  return(-c * (sqrt(1 - pow(t, 2)) - 1) + b)
end

local function outCirc(t, b, c, d)
  t = t / d - 1
  return(c * sqrt(1 - pow(t, 2)) + b)
end

local function inOutCirc(t, b, c, d)
  t = t / d * 2
  if t < 1 then
    return -c / 2 * (sqrt(1 - t * t) - 1) + b
  else
    t = t - 2
    return c / 2 * (sqrt(1 - t * t) + 1) + b
  end
end

local function outInCirc(t, b, c, d)
  if t < d / 2 then
    return outCirc(t * 2, b, c / 2, d)
  else
    return inCirc((t * 2) - d, b + c / 2, c / 2, d)
  end
end

local function inElastic(t, b, c, d, a, p)
  if t == 0 then return b end

  t = t / d

  if t == 1 then return b + c end

  if not p then p = d * 0.3 end

  local s

  if not a or a < abs(c) then
    a = c
    s = p / 4
  else
    s = p / (2 * pi) * asin(c/a)
  end

  t = t - 1

  return -(a * pow(2, 10 * t) * sin((t * d - s) * (2 * pi) / p)) + b
end

-- a: amplitud
-- p: period
local function outElastic(t, b, c, d, a, p)
  if t == 0 then return b end

  t = t / d

  if t == 1 then return b + c end

  if not p then p = d * 0.3 end

  local s

  if not a or a < abs(c) then
    a = c
    s = p / 4
  else
    s = p / (2 * pi) * asin(c/a)
  end

  return a * pow(2, -10 * t) * sin((t * d - s) * (2 * pi) / p) + c + b
end

-- p = period
-- a = amplitud
local function inOutElastic(t, b, c, d, a, p)
  if t == 0 then return b end

  t = t / d * 2

  if t == 2 then return b + c end

  if not p then p = d * (0.3 * 1.5) end
  if not a then a = 0 end

  if not a or a < abs(c) then
    a = c
    s = p / 4
  else
    s = p / (2 * pi) * asin(c / a)
  end

  if t < 1 then
    t = t - 1
    return -0.5 * (a * pow(2, 10 * t) * sin((t * d - s) * (2 * pi) / p)) + b
  else
    t = t - 1
    return a * pow(2, -10 * t) * sin((t * d - s) * (2 * pi) / p ) * 0.5 + c + b
  end
end

-- a: amplitud
-- p: period
local function outInElastic(t, b, c, d, a, p)
  if t < d / 2 then
    return outElastic(t * 2, b, c / 2, d, a, p)
  else
    return inElastic((t * 2) - d, b + c / 2, c / 2, d, a, p)
  end
end

local function inBack(t, b, c, d, s)
  if not s then s = 1.70158 end
  t = t / d
  return c * t * t * ((s + 1) * t - s) + b
end

local function outBack(t, b, c, d, s)
  if not s then s = 1.70158 end
  t = t / d - 1
  return c * (t * t * ((s + 1) * t + s) + 1) + b
end

local function inOutBack(t, b, c, d, s)
  if not s then s = 1.70158 end
  s = s * 1.525
  t = t / d * 2
  if t < 1 then
    return c / 2 * (t * t * ((s + 1) * t - s)) + b
  else
    t = t - 2
    return c / 2 * (t * t * ((s + 1) * t + s) + 2) + b
  end
end

local function outInBack(t, b, c, d, s)
  if t < d / 2 then
    return outBack(t * 2, b, c / 2, d, s)
  else
    return inBack((t * 2) - d, b + c / 2, c / 2, d, s)
  end
end

local function outBounce(t, b, c, d)
  t = t / d
  if t < 1 / 2.75 then
    return c * (7.5625 * t * t) + b
  elseif t < 2 / 2.75 then
    t = t - (1.5 / 2.75)
    return c * (7.5625 * t * t + 0.75) + b
  elseif t < 2.5 / 2.75 then
    t = t - (2.25 / 2.75)
    return c * (7.5625 * t * t + 0.9375) + b
  else
    t = t - (2.625 / 2.75)
    return c * (7.5625 * t * t + 0.984375) + b
  end
end

local function inBounce(t, b, c, d)
  return c - outBounce(d - t, 0, c, d) + b
end

local function inOutBounce(t, b, c, d)
  if t < d / 2 then
    return inBounce(t * 2, 0, c, d) * 0.5 + b
  else
    return outBounce(t * 2 - d, 0, c, d) * 0.5 + c * .5 + b
  end
end

local function outInBounce(t, b, c, d)
  if t < d / 2 then
    return outBounce(t * 2, b, c / 2, d)
  else
    return inBounce((t * 2) - d, b + c / 2, c / 2, d)
  end
end

-- Modifications for Daneel : replaced 'return {' by 'Tween.Ease = {'
Tween.Ease = {
  linear = linear,
  inQuad = inQuad,
  outQuad = outQuad,
  inOutQuad = inOutQuad,
  outInQuad = outInQuad,
  inCubic = inCubic ,
  outCubic = outCubic,
  inOutCubic = inOutCubic,
  outInCubic = outInCubic,
  inQuart = inQuart,
  outQuart = outQuart,
  inOutQuart = inOutQuart,
  outInQuart = outInQuart,
  inQuint = inQuint,
  outQuint = outQuint,
  inOutQuint = inOutQuint,
  outInQuint = outInQuint,
  inSine = inSine,
  outSine = outSine,
  inOutSine = inOutSine,
  outInSine = outInSine,
  inExpo = inExpo,
  outExpo = outExpo,
  inOutExpo = inOutExpo,
  outInExpo = outInExpo,
  inCirc = inCirc,
  outCirc = outCirc,
  inOutCirc = inOutCirc,
  outInCirc = outInCirc,
  inElastic = inElastic,
  outElastic = outElastic,
  inOutElastic = inOutElastic,
  outInElastic = outInElastic,
  inBack = inBack,
  outBack = outBack,
  inOutBack = inOutBack,
  outInBack = outInBack,
  inBounce = inBounce,
  outBounce = outBounce,
  inOutBounce = inOutBounce,
  outInBounce = outInBounce,
}
