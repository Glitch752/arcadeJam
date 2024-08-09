export const playerPosition = { x: 0, y: 0 };
const playerSpeed = 400;
let tileWidthPixels = 10;

const heldKeys = new Set<string>();
export function initControls() {
    window.addEventListener('keydown', (event) => {
        heldKeys.add(event.key.toLowerCase());
    });
    
    window.addEventListener('keyup', (event) => {
        heldKeys.delete(event.key.toLowerCase());
    });

    window.addEventListener('wheel', (event) => {
        tileWidthPixels *= 1 + event.deltaY / -1000;
        tileWidthPixels = Math.max(1, tileWidthPixels);
        tileWidthPixels = Math.min(100, tileWidthPixels);
    });
}

let windowSizeUniformBuffer: GPUBuffer | undefined;
export function createWindowSizeUniformBuffer(device: GPUDevice): GPUBuffer {
    windowSizeUniformBuffer = device.createBuffer({
        size: Float32Array.BYTES_PER_ELEMENT * 5,
        usage: GPUBufferUsage.UNIFORM | GPUBufferUsage.COPY_DST,
        label: 'Window size uniform buffer',
    });
    return windowSizeUniformBuffer;
}

function updateWindowSizeUniformBuffer(device: GPUDevice) {
    if(windowSizeUniformBuffer === undefined) {
        throw new Error('Window size uniform buffer not initialized');
    }

    const buffer = new Float32Array(5);
    buffer[0] = window.innerWidth;
    buffer[1] = window.innerHeight;
    buffer[2] = playerPosition.x;
    buffer[3] = playerPosition.y;
    buffer[4] = tileWidthPixels;
    device.queue.writeBuffer(windowSizeUniformBuffer, 0, buffer);
}

export function updateMovement(elapsed: number, device: GPUDevice) {
    if (heldKeys.has('arrowup') || heldKeys.has('w')) {
        playerPosition.y -= playerSpeed * elapsed;
    }
    if (heldKeys.has('arrowdown') || heldKeys.has('s')) {
        playerPosition.y += playerSpeed * elapsed;
    }
    if (heldKeys.has('arrowleft') || heldKeys.has('a')) {
        playerPosition.x -= playerSpeed * elapsed;
    }
    if (heldKeys.has('arrowright') || heldKeys.has('d')) {
        playerPosition.x += playerSpeed * elapsed;
    }

    updateWindowSizeUniformBuffer(device);
}