import './style.css'
import init from './init';

let resizeListeners: ((width: number, height: number) => void)[] = [];
export function addResizeHandler(callback: (width: number, height: number) => void) {
  resizeListeners.push(callback);
}

(async () => {
  if (navigator.gpu === undefined) {
    alert('WebGPU is not supported in this browser.');
    return;
  }
  const adapter = await navigator.gpu.requestAdapter();
  if (adapter === null) {
    alert('No adapter is available for WebGPU.');
    return;
  }
  const device = await adapter.requestDevice();

  const canvas = document.querySelector<HTMLCanvasElement>('#webgpu-canvas');
  if(canvas === null) {
    alert('No canvas found');
    return;
  }

  const observer = new ResizeObserver(() => {
    canvas.width = canvas.clientWidth;
    canvas.height = canvas.clientHeight;

    for (const listener of resizeListeners) {
      listener(canvas.clientWidth, canvas.clientHeight);
    }
  });

  observer.observe(canvas);
  const context = canvas.getContext('webgpu') as GPUCanvasContext;

  init(context, device);
})();