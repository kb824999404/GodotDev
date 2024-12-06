import noise
import numpy as np
import matplotlib.pyplot as plt
import json
import random
import ipdb

offsets = [
    (1,0),(-1,0),(0,1),(0,-1)
]

def mapToStr(data):
    lines = []
    for line in data:
        lines.append(",".join([ str(item) for item in line.tolist()  ]))
    return "\n".join(lines)

def dfs_fill(world_id,value,pos,shape):
    y,x = pos
    if world_id[y,x] == value:
        return
    world_id[y,x] = value
    for dy,dx in offsets:
        y1,x1 = y+dy,x+dx
        if y1>=0 and y1<shape[0] and x1>=0 and x1<shape[1] and  world_id[y1,x1] != value:
            dfs_fill(world_id,value,(y1,x1),shape)

def dfs_water(world_id,visited,pos,shape):
    y,x = pos
    for dy,dx in offsets:
        y1,x1 = y+dy,x+dx
        if y1>=0 and y1<shape[0] and x1>=0 and x1<shape[1] and not visited[y1,x1]:
            if world_id[y1,x1] == 3:  # water
                visited[y1,x1] = True
                dfs_water(world_id,visited,(y1,x1),shape)
            elif world_id[y1,x1] == 0: # grass
                visited[y1,x1] = True
                world_id[y1,x1] = 2   # set as soil

def dfs_soil(world_id,visited,pos,shape):
    y,x = pos
    for dy,dx in offsets:
        y1,x1 = y+dy,x+dx
        if y1>=0 and y1<shape[0] and x1>=0 and x1<shape[1] and not visited[y1,x1]:
            if world_id[y1,x1] == 2:  # soil
                visited[y1,x1] = True
                dfs_soil(world_id,visited,(y1,x1),shape)
            elif world_id[y1,x1] == 0: # grass
                visited[y1,x1] = True
                world_id[y1,x1] = 2   # set as soil

def get_pnoise(shape,scale,octaves,persistence,lacunarity,delta=(0,0)):
    data = np.zeros(shape)
    for y in range(shape[0]):
        for x in range(shape[1]):
            n = noise.pnoise2(y/scale+delta[0],
                            x/scale+delta[1],
                            octaves=octaves,
                            persistence=persistence,
                            lacunarity=lacunarity)
            data[y,x]=n
    data = ( data + 1.0 ) / 2.0
    return data

if __name__=="__main__":
    random.seed(824)
    # 是否显示结果
    result_show = False
    ################ 生成世界 ################
    block_size = 2

    # 生成2D柏林噪声
    shape = (64,64)
    scale = 10.0
    octaves = 2         # 噪声的细节层次
    persistence = 0.1   # 控制每个八度音程的振幅衰减
    lacunarity = 2.0    # 控制每个八度音程的频率增加
    world = get_pnoise(shape,scale,octaves,persistence,lacunarity)


    world_id = np.zeros(shape,dtype=np.int32)
    world_rgb = np.zeros((shape[0],shape[1],3))
    colors = np.array([ 
        [134,193,102],  # grass:0
        [100,100,100],  # stone:1
        [176,119,54],   # soil:2
        [46,169,223],   # water:3
    ])
    block_ids = [
        # 1,
        0,      # grass
        # 2,
        3,      # water
    ]
    gradients = [ 
        # 0.28,
        0.65,
        # 0.70,
    ]

    # 根据梯度和颜色分配给world_rgb
    for y in range(shape[0]):
        for x in range(shape[1]):
            value = world[y, x]
            for i in range(len(gradients)):
                if value < gradients[i]:
                    world_id[y, x] = block_ids[i]
                    break
            if value > gradients[-1]:
                world_id[y, x] = block_ids[-1]
    
    # 水的边缘设置为土地
    visited = np.full(shape,fill_value=False,dtype=np.bool_)
    for y in range(shape[0]):
        for x in range(shape[1]):
            if world_id[y,x] == 3 and not visited[y,x]:
                visited[y,x] = True
                dfs_water(world_id,visited,(y,x),shape)
    # 土地的边缘设置为土地
    visited = np.full(shape,fill_value=False,dtype=np.bool_)
    for y in range(shape[0]):
        for x in range(shape[1]):
            if world_id[y,x] == 2 and not visited[y,x]:
                visited[y,x] = True
                dfs_soil(world_id,visited,(y,x),shape)

    # 边缘一律设置为草地
    for y in range(shape[0]):
        dfs_fill(world_id,0,(y,0),shape)
        dfs_fill(world_id,0,(y,shape[1]-1),shape)
    for x in range(shape[1]):
        dfs_fill(world_id,0,(0,x),shape)
        dfs_fill(world_id,0,(shape[0]-1,x),shape)

    # RGB可视化
    world_rgb = colors[world_id]


    # 显示结果
    if result_show:
        # 创建包含三个子图的图形，1行3列
        fig, (ax1, ax2, ax3) = plt.subplots(1, 3, figsize=(10, 5))

        # 在第一个子图中绘制直方图
        ax1.hist(world.flatten(), bins=50, facecolor='skyblue', edgecolor='black')
        ax1.set_xlabel('Value')
        ax1.set_ylabel('Frequency')
        ax1.set_title('Histogram of World')

        # 在第二个子图中显示world_rgb图像
        ax2.imshow(world_rgb.astype(np.uint8))
        ax2.set_title('World RGB Image')
        # ax2.imshow(world_id.astype(np.uint8),cmap='gray')
        # ax2.set_title('World ID Image')

        # 在第三个子图中绘制world（灰度形式）
        ax3.imshow(world, cmap='gray')
        ax3.set_title('World (Gray)')
        # plt.savefig("world_id.jpg")
        plt.show()

    # 填充边界
    # world_pad = np.full((shape[0]+2,shape[1]+2),fill_value=-1,dtype=np.int32)
    # world_pad[1:-1,1:-1] = world_id[:,:]
    # print(mapToStr(world_pad))
    world_saved = [ [  str(item)  for item in line ] for line in world_id  ]

    ########################################
    
    ################ 生成植物 ################
    shapePlant = (shape[0]*2,shape[1]*2)
    # 温度
    scale = 10.0
    octaves = 2         # 噪声的细节层次
    persistence = 0.1   # 控制每个八度音程的振幅衰减
    lacunarity = 2.0    # 控制每个八度音程的频率增加
    delta = (20,20)
    map_heat = get_pnoise(shape,scale,octaves,persistence,lacunarity,delta)
    map_heat = ( map_heat - np.min(map_heat) ) / ( np.max(map_heat) - np.min(map_heat) )

    # 土壤深度
    scale = 5.0    
    octaves = 2         # 噪声的细节层次
    persistence = 0.1   # 控制每个八度音程的振幅衰减
    lacunarity = 2.0    # 控制每个八度音程的频率增加
    delta = (50,50)
    map_depth = get_pnoise(shape,scale,octaves,persistence,lacunarity,delta)
    map_depth = ( map_depth - np.min(map_depth) ) / ( np.max(map_depth) - np.min(map_depth) )

    # 土壤湿度
    scale = 5.0    
    octaves = 2         # 噪声的细节层次
    persistence = 0.1   # 控制每个八度音程的振幅衰减
    lacunarity = 2.0    # 控制每个八度音程的频率增加
    delta = (80,80)
    map_wet = get_pnoise(shape,scale,octaves,persistence,lacunarity,delta)
    map_wet = ( map_wet - np.min(map_wet) ) / ( np.max(map_wet) - np.min(map_wet) )

    plants = []
    depthGradients = [ 0.6,0.56,0.52 ]
    treeColors = [ "blue","green","red" ]
    prob_tree = 0.4
    prob_others = 0.09

    # 生成树
    for y in range(0,shape[0]*2,4):
        for x in range(0,shape[1]*2,4):
            y1,x1 = y//2,x//2
            if world_id[y1,x1] not in [0]:
                continue
            if random.random() > prob_tree:
                continue
            depth = map_depth[y1,x1]
            heat = map_heat[y1,x1]
            wet = map_wet[y1,x1]
            plantName = None
            plantType = None
            pos = (y1+0.5,x1+0.5)
            # 深度最大，生成树
            if depth > depthGradients[0]:
                plantType = "tree"
                # 根据深度确定树高度
                treeHeight =  int(np.ceil((depth-depthGradients[0])/(1.0-depthGradients[0]) * 3))
                if treeHeight < 1:
                    treeHeight = 1
                # 根据温度确定树颜色
                if heat < 0.4:
                    treeColor = treeColors[0]
                elif heat < 0.6:
                    treeColor = treeColors[1]
                else:
                    treeColor = treeColors[2]
                plantName = f"trees/tree_1_{treeHeight}_{treeColor}"
            if plantName:
                plants.append({
                    "type": plantType,
                    "name": plantName,
                    "pos": pos
                })
    print("Tree Count:",len(plants))

    # 生成植物
    for y in range(shape[0]*2):
        for x in range(shape[1]*2):
            y1,x1 = y//2,x//2
            if world_id[y1,x1] not in [0,2]:
                continue
            if random.random() > prob_others:
                continue
            depth = map_depth[y1,x1]
            heat = map_heat[y1,x1]
            wet = map_wet[y1,x1]
            plantName = None
            plantType = None
            pos = (y/2-0.25,x/2-0.25)
            # 先判断深度
            if depth < depthGradients[0] and depth > depthGradients[1]:
            # 深度中间，生成花
                plantType = "flower"
                # 根据湿度确定花类型
                flowerType = int(np.ceil(heat*2.0))
                # 根据温度确定花颜色
                flowerColor = int(np.ceil(wet*2.0))
                plantName = f"flowers/flower_{flowerType}_{flowerColor}"
            elif depth > depthGradients[2]:
            # 深度最小，生成草
                plantType = "grass"
                # 根据湿度确定草类型
                grassType = int(np.ceil(heat*4.0))
                grassIndex = int(np.ceil(wet*3.0))
                plantName = f"grass/grass_{grassType}_{grassIndex}"
            if plantName:
                plants.append({
                    "type": plantType,
                    "name": plantName,
                    "pos": pos
                })
    print("Plants Count:",len(plants))
    # 显示结果
    if result_show:
        # 创建包含三个子图的图形，1行3列
        fig, ((ax11, ax12, ax13), (ax21, ax22, ax23)) = plt.subplots(2, 3, figsize=(12, 8))

        ax11.imshow(map_heat, cmap='gray')
        ax11.set_title('Heat')

        ax12.imshow(map_depth, cmap='gray')
        ax12.set_title('Depth')

        ax13.imshow(map_wet, cmap='gray')
        ax13.set_title('Wet')

        ax21.hist(map_heat.flatten(), bins=50, facecolor='skyblue', edgecolor='black')
        ax21.set_xlabel('Value')
        ax21.set_ylabel('Frequency')
        ax21.set_title('Histogram of Heat')

        ax22.hist(map_depth.flatten(), bins=50, facecolor='skyblue', edgecolor='black')
        ax22.set_xlabel('Value')
        ax22.set_ylabel('Frequency')
        ax22.set_title('Histogram of Depth')

        ax23.hist(map_wet.flatten(), bins=50, facecolor='skyblue', edgecolor='black')
        ax23.set_xlabel('Value')
        ax23.set_ylabel('Frequency')
        ax23.set_title('Histogram of Wet')

        plt.show()

    ########################################

    with open("map02.json","w") as f:
        json.dump({
            "map_size": list(shape),
            "block_size": block_size,
            "map": world_saved,
            "plants": plants,
        },f,indent=4)