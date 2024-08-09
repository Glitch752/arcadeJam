export enum TileType {
    Empty = 0,
    Wall = 1,
    Water = 2,
}

export type Tile = {
    type: TileType
};

export const mapWidth = 30000;
export const mapHeight = 200;
export const map: Tile[] = new Array(mapWidth * mapHeight);

let storageBuffer: GPUBuffer | undefined;

export function initMapStorageBuffer(device: GPUDevice): GPUBuffer {
    storageBuffer = device.createBuffer({
        size: map.length * 4,
        usage: GPUBufferUsage.STORAGE | GPUBufferUsage.COPY_DST,
        mappedAtCreation: true,
    });
    return storageBuffer;
}

const simple1DNoise = () => {
    const MAX_VERTICES = 256, MAX_VERTICES_MASK = MAX_VERTICES - 1;
    let amplitude = 1, scale = 1;
    const r = new Array(MAX_VERTICES).fill(0).map(() => Math.random());
    return {
        getVal: (x) => {
            const scaledX = x * scale, xFloor = Math.floor(scaledX), t = scaledX - xFloor;
            const lerp = (a, b, t) => a * (1-t) + b * t;
            const xMin = xFloor % MAX_VERTICES_MASK, xMax = (xMin + 1) % MAX_VERTICES_MASK;
            return lerp(r[xMin], r[xMax], t * t * (3 - 2 * t)) * amplitude;
        },
        setAmplitude: (newAmplitude) => { amplitude = newAmplitude },
        setScale: (newScale) => { scale = newScale }
    };
};

export function initMap() {
    if(storageBuffer === undefined) {
        throw new Error('Storage buffer not initialized');
    }

    const start = Date.now();

    const storage = new Uint32Array(storageBuffer.getMappedRange());
    const noise = simple1DNoise();
    for (let x = 0; x < mapWidth; x++) {
        const noiseVal = noise.getVal(x / 50);
        for (let y = 0; y < mapHeight; y++) {
            const index = y * mapWidth + x;
            if(x === 0 || x === mapWidth - 1 || y === 0 || y === mapHeight - 1) {
                map[index] = { type: TileType.Wall };
            } else {
                if(y > noiseVal * 50 + 50) {
                    if (Math.random() < 0.5) {
                        map[index] = { type: TileType.Wall };
                    } else {
                        map[index] = { type: TileType.Water };
                    }
                } else if(y > noiseVal * 50 + 20) {
                    map[index] = { type: TileType.Water };
                } else {
                    map[index] = { type: TileType.Empty };
                }
            }

            storage[index] = map[index].type;
        }
    }

    console.log(`Generated ${mapWidth*mapHeight} tiles in ${Date.now() - start}ms`);

    storageBuffer.unmap();
}