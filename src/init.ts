// Note: You can import your separate WGSL shader files like this.
import { initMap, initMapStorageBuffer, mapHeight, mapWidth } from './map';
import { createWindowSizeUniformBuffer, initControls, updateMovement } from './movement';

import mapWGSL from './shaders/map.wgsl';
import bloomWGSL from './shaders/bloom.wgsl';
import { addResizeHandler } from './main';

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

  const { mapRenderPipeline, mapBindGroup } = createMapPipeline(device, presentationFormat);

  let postprocessingRenderTexture = device.createTexture({
    size: [window.innerWidth, window.innerHeight],
    format: presentationFormat,
    usage: GPUTextureUsage.COPY_SRC | GPUTextureUsage.RENDER_ATTACHMENT | GPUTextureUsage.TEXTURE_BINDING,
  });
  // addResizeHandler((width, height) => {
  //   postprocessingRenderTexture.destroy();
  //   postprocessingRenderTexture = device.createTexture({
  //     size: [width, height],
  //     format: presentationFormat,
  //     usage: GPUTextureUsage.COPY_SRC | GPUTextureUsage.RENDER_ATTACHMENT | GPUTextureUsage.TEXTURE_BINDING,
  //   });
  // });
  const { bloomPipeline, bloomBindGroup } = createBloomPipeline(device, presentationFormat, postprocessingRenderTexture.createView());

  initControls();

  let lastTimestamp = 0;
  const frame = (timestamp: number) => {
    const elapsed = (timestamp - lastTimestamp) / 1000;
    lastTimestamp = timestamp;
    
    // Update game state
    updateMovement(elapsed, device);

    // Render the
    const commandEncoder = device.createCommandEncoder();

    const postprocessingView = postprocessingRenderTexture.createView();
    const mapPassEncoder = commandEncoder.beginRenderPass(
      { colorAttachments: [
        { view: postprocessingView, clearValue: { r: 0.0, g: 0.0, b: 0.3, a: 1.0 }, loadOp: 'clear', storeOp: 'store' }
      ] }
    );
    mapPassEncoder.setPipeline(mapRenderPipeline);
    mapPassEncoder.setBindGroup(0, mapBindGroup);
    mapPassEncoder.draw(3, 1, 0, 0);
    mapPassEncoder.end();

    // Render postprocessing
    const screenView = context.getCurrentTexture().createView();
    const bloomPassEncoder = commandEncoder.beginRenderPass(
      { colorAttachments: [
        { view: screenView, clearValue: { r: 0.0, g: 0.0, b: 0.3, a: 1.0 }, loadOp: 'clear', storeOp: 'store' }
      ] }
    );
    bloomPassEncoder.setPipeline(bloomPipeline);
    bloomPassEncoder.setBindGroup(0, bloomBindGroup);
    bloomPassEncoder.draw(3, 1, 0, 0);
    bloomPassEncoder.end();

    device.queue.submit([commandEncoder.finish()]);

    requestAnimationFrame(frame);
  }

  requestAnimationFrame(frame);
}

function createMapPipeline(device: GPUDevice, presentationFormat: GPUTextureFormat): {
  mapRenderPipeline: GPURenderPipeline,
  mapBindGroup: GPUBindGroup,
} {
  const mapShaderModule = device.createShaderModule({
    code: mapWGSL,
    label: 'Map shader',
  });
  const mapRenderPipeline = device.createRenderPipeline({
    layout: 'auto',
    label: "Map render pipeline",
    vertex: {
      module: mapShaderModule,
      entryPoint: 'vs_main',
    },
    fragment: {
      module: mapShaderModule,
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
  const mapBindGroup = device.createBindGroup({
    layout: mapRenderPipeline.getBindGroupLayout(0),
    label: 'Map bind group',
    entries: [
      { binding: 0, resource: { buffer: mapStorageBuffer } },
      { binding: 1, resource: { buffer: windowSizeUniformBuffer } }
    ],
  });

  return { mapRenderPipeline, mapBindGroup };
}

function createBloomPipeline(device: GPUDevice, presentationFormat: GPUTextureFormat, postprocessingRenderTexture: GPUTextureView): {
  bloomPipeline: GPURenderPipeline,
  bloomBindGroup: GPUBindGroup,
} {
  const bloomModule = device.createShaderModule({
    code: bloomWGSL,
    label: 'Bloom shader',
  });

  const bloomPipeline = device.createRenderPipeline({
    layout: 'auto',
    label: "Bloom render pipeline",
    vertex: {
      module: bloomModule,
      entryPoint: 'vs_main'
    },
    fragment: {
      module: bloomModule,
      entryPoint: 'fs_main',
      targets: [{ format: presentationFormat }],
      constants: {}
    },
    primitive: {
      topology: 'triangle-list',
    },
  });
  const bloomSampler = device.createSampler({
    magFilter: 'linear',
    minFilter: 'linear',
  });
  const bloomBindGroup = device.createBindGroup({
    layout: bloomPipeline.getBindGroupLayout(0),
    label: 'Bloom bind group',
    entries: [
      { binding: 0, resource: postprocessingRenderTexture },
      { binding: 1, resource: bloomSampler }
    ],
  });

  return { bloomPipeline, bloomBindGroup };
}