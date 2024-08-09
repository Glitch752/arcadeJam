// Note: You can import your separate WGSL shader files like this.
import { initMap, initMapStorageBuffer, mapHeight, mapWidth } from './map';
import { createWindowSizeUniformBuffer, initControls, updateMovement } from './movement';
import mapWGSL from './shaders/map.wgsl';

export default function init(
  context: GPUCanvasContext,
  device: GPUDevice
): void {
  const presentationFormat = navigator.gpu.getPreferredCanvasFormat();
  context.configure({
    device,
    format: presentationFormat,
    alphaMode: 'opaque',
  });

  const shaderModule = device.createShaderModule({
    code: mapWGSL,
    label: 'Map shader',
  });

  const pipeline = device.createRenderPipeline({
    layout: 'auto',
    label: "Map render pipeline",
    vertex: {
      module: shaderModule,
      entryPoint: 'vs_main',
    },
    fragment: {
      module: shaderModule,
      entryPoint: 'fs_main',
      targets: [{ format: presentationFormat }],
      constants: {
        MAP_WIDTH: mapWidth,
        MAP_HEIGHT: mapHeight
      }
    },
    primitive: {
      topology: 'triangle-list',
    },
  });

  const mapStorageBuffer = initMapStorageBuffer(device);
  initMap();

  const windowSizeUniformBuffer = createWindowSizeUniformBuffer(device);

  const bindGroup = device.createBindGroup({
    layout: pipeline.getBindGroupLayout(0),
    label: 'Map bind group',
    entries: [
      { binding: 0, resource: { buffer: mapStorageBuffer } },
      { binding: 1, resource: { buffer: windowSizeUniformBuffer } }
    ],
  });

  initControls();

  let lastTimestamp = 0;
  const frame = (timestamp: number) => {
    const elapsed = (timestamp - lastTimestamp) / 1000;
    lastTimestamp = timestamp;
    
    // Update game state
    updateMovement(elapsed, device);

    // Render
    const commandEncoder = device.createCommandEncoder();
    const textureView = context.getCurrentTexture().createView();

    const renderPassDescriptor: GPURenderPassDescriptor = {
      colorAttachments: [
        {
          view: textureView,
          clearValue: { r: 0.0, g: 0.0, b: 0.3, a: 1.0 },
          loadOp: 'clear',
          storeOp: 'store',
        },
      ],
    };

    const passEncoder = commandEncoder.beginRenderPass(renderPassDescriptor);
    passEncoder.setPipeline(pipeline);
    passEncoder.setBindGroup(0, bindGroup);
    passEncoder.draw(3, 1, 0, 0);
    passEncoder.end();

    device.queue.submit([commandEncoder.finish()]);

    requestAnimationFrame(frame);
  }

  requestAnimationFrame(frame);
}
