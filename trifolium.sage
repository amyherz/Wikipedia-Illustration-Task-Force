reset()
from sage.plot.circle import Circle
from sage.plot.arc import Arc
interval = 80
dist = 2.5  #larger in proportion to dist2 --> sharper points, smaller leaves
dist2 = 2.5  #larger --> larger leaves
initangle = 0  #rotates figure initangle radians about origin
jointradius = 1/2  #determines number of leaves
Reverse = True  #Sets Direction of Arm 2 Relative to Arm 1
k = 1/jointradius
window = dist+dist2+0.5

def InputEquation():
    # NOTE: Enter the equation in the form, ' a * cos(b*theta + c) '  OR  ' a * sin(b*theta + c) '
    # Replace 'a' 'b' and 'c' with constants. Spacing does not matter.
    # e.g. 4*cos(2*theta)
    eqn = str("6*cos(3*theta+pi/2)") #enter equation here  ********************************************
                                     #                     ********************************************
    
    eqn = eqn.split("*")
    vals = []
    for i in range(3-len(eqn)):
        eqn.append('')
    if 'theta' in eqn[0]:
        eqn[2] = eqn[0]
        eqn[0] = '1'
        eqn[1] = '1'
    if 'theta' in eqn[1]:
        eqn[2] = eqn[1]
        eqn[1] = eqn[0]
        eqn[0] = '1'
    for i in eqn:
        index = eqn.index(i)
        i = i.replace(' ','')
        if i[0] == 'c':
            trig = 1
            i = i.replace('cos(','')
        elif i[0] == 's':
            trig = 2
            i = i.replace('sin(','')
        i = i.replace(')','')
        i = i.replace('theta','')
        i = i.replace('+','')
        if i == '':
            if index in [0,1]:
                i = '1'
            else:
                i = '0'
        eqn[index] = i
    for i in range(len(eqn)):
        eqn[i] = eval(eqn[i])
    print(eqn,trig)
    return [eqn,trig]
    
def InterpretEquation(eqn):
    initangle = 0
    dist = dist2 = eqn[0][0]/2
    if eqn[1] == 2:
        initangle = pi/4
    rotation = 2*eqn[0][2]/eqn[0][1]
    initangle = initangle - rotation
    if eqn[0][1] % 2 == 0:
        jointradius = 1/(2*eqn[0][1]-1)
    else:
        jointradius = 1/(eqn[0][1]-1)
    k = 1/jointradius
    window = dist+dist2+0.5
    return [dist,dist2,initangle,jointradius,k,window]

def crank(t):
    pnt = point((cos(t), sin(t)),size=50, color='red')
    crk = line( [ (0.0,0.0), (cos(t),sin(t)) ], color='red')
    fig = pnt + crk
    return fig

def wheel2(t):
    if Reverse == True:
        r = -1
    else:
        r = 1
    pnt = point((jointradius*cos(r*k*t)+dist*cos(t), jointradius*sin(r*k*t)+dist*sin(t)),size=50)
    crk = line([(dist*cos(t),dist*sin(t)), (jointradius*cos(r*k*t)+dist*cos(t),jointradius*sin(r*k*t)+dist*sin(t))])

    fig = pnt + crk
    return fig
    
def DrawCurve(t,curve,i):
    if i>0:
        partcurve = line([ (Points[i-1][0],Points[i-1][1]), (Points[i][0],Points[i][1]) ], color='green')
    else:
        partcurve = line([(0,0),(0,0)])
    curve += partcurve
    return curve
    
def DrawCircles(t):
    crank = circle((0,0),1)
    wheel2 = circle((dist*cos(t),dist*sin(t)),jointradius)
    return crank+wheel2
    
def DrawChain(t):
    #top of chain:    Pa --> Pb
    #bottom of chain: Qb --> Qa
    # Pa : ( cos(theta + t), sin(theta + t) )
    # Qa : ( cos(t - theta), sin(t - theta) )
    # Pb : ( , )
    # Qb : ( , )
    # theta = arccos( (1-jointradius) / dist )
    # thetap = 2*pi - theta
    # Bx = dist*cos(t)
    # By = dist*sin(t)
    
    Bx = dist*cos(t)
    By = dist*sin(t)
    theta = arccos( (1-jointradius) / dist )
    theta2 = pi - theta
    
    #Intialize Starting Points of Chain at Circle B
    Pbi = [ dist + jointradius*cos(theta), jointradius*sin(theta) ]
    Qbi = [ dist + jointradius*cos(theta), jointradius*sin(-theta) ]
    
    #Find Length, l, of Origin --> Pbi and Origin --> Qbi
    l = sqrt(dist^2 + jointradius^2 - 2*dist*jointradius*cos(theta2))
    
    #Calculate Rotation phi1 @ line(origin, Pbi) and phi2 @ line(origin, Qbi)
    phi = tan(Pbi[1] / Pbi[0])
    
    #Draw Chains
    chaintop = line([ (cos(theta + t), sin(theta + t)), ( l*cos(t+phi), l*sin(t+phi)) ], color = 'black') #fix x distance here
    chainbottom = line([ (l*cos(t-phi), l*sin(t-phi)), (cos(t-theta), sin(t-theta))], color = 'black')
    
    chain = chaintop + chainbottom
    return chain
    
def DrawArm1(t):
    l = sqrt( dist^2 + 0.1^2 )
    phi = arctan( 0.1 / dist )
    
    armtop = line([(0.1*cos(t+pi/2),0.1*sin(t+pi/2)),(l*cos(t+phi),l*sin(t+phi))])
    armbottom = line([(0.1*cos(t-pi/2),0.1*sin(t-pi/2)),(l*cos(t-phi),l*sin(t-phi))])
    ends = arc((0,0), 0.1, sector=(t+pi/2,t+3*pi/2))+arc((dist*cos(t),dist*sin(t)), 0.1, sector=(t-pi/2,t+pi/2))
    arm = armtop+armbottom+ends
    return arm
    
def DrawArm2(t):
    #NEEDED VARIABLES
    # l = length of arm
    # theta = angle of joint relative to origin (circle B's rotation : A)
    # phi = angle of arm2 relative to joint (circle C's rotation : B)
    # Bx = Center of Circle B's x coordinate
    # By = Center of Circle B's y coordinate
    # Cx = Center of Circle C's x coordinate
    # Cy = Center of Circle C's y coordinate
    
    l1 = sqrt( dist^2 + 0.1^2 )
    l2 = sqrt( dist2^2 + 0.1^2 )
    phi = arctan( 0.1 / dist2 ) #not earlier phi
    Bx = dist*cos(t)
    By = dist*sin(t)
    if Reverse == True:
        t = -t
    Cx = Bx + dist2*cos(k*t)
    Cy = By + dist2*sin(k*t)
    
    #crudearm = line([ (Bx, By), (Cx, Cy) ])
    #arm = crudearm
    ia = initangle
    armtop = line([ (Bx + 0.1*cos(k*t+ia+pi/2), By + 0.1*sin(k*t+ia+pi/2)), (Bx + l2*cos(k*t+ia+phi), By + l2*sin(k*t+ia+phi)) ])
    armbottom = line([ (Bx + 0.1*cos(k*t+ia-pi/2), By + 0.1*sin(k*t+ia-pi/2)), (Bx + l2*cos(k*t+ia-phi), By + l2*sin(k*t+ia-phi)) ])
    ends = arc((Bx,By), 0.1, sector=(k*t+ia+pi/2,k*t+ia+3*pi/2))+arc((Bx+dist2*cos(k*t+ia),By+dist2*sin(k*t+ia)), 0.1, sector=(k*t+ia-pi/2,k*t+ia+pi/2))
    arm = armtop + armbottom + ends
    return arm
    
def SavePoint(t):
    Bx = dist*cos(t)
    By = dist*sin(t)
    if Reverse == True:
        t = -t
    Cx = Bx + dist2*cos(k*t+initangle)
    Cy = By + dist2*sin(k*t+initangle)
    Points.append([Cx,Cy])
    
frames = []
curve = line([(0,0),(0,0)])
Points = []
eqn = InputEquation()
vars = InterpretEquation(eqn) #vars = [dist,dist2,initangle,jointradius,k,window]
dist = dist2 = vars[0]
initangle = vars[2]
jointradius = vars[3]
k = vars[4]
window = vars[5]
for t in range(interval+1):
    tp = 2*pi*t/interval #time prime or time particular
    SavePoint(tp)
    curve = DrawCurve(tp,curve,t)
    circles = DrawCircles(tp)
    chain = DrawChain(tp)
    arm = DrawArm1(tp)
    arm2 = DrawArm2(tp)
    frames.append(circles+crank(tp)+wheel2(tp)+chain+arm+arm2+curve)

a = animate(frames, aspect_ratio=1, xmin=-window, xmax=window, ymin=-window, ymax=window)
a.show()
frames[-1].show()
