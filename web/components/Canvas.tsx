
import React, { useState, useRef, useEffect } from 'react';
import { CanvasItem } from '../types';
import { 
  Loader2, Trash2, Wand2, PenTool, Type, 
  Sparkles, ChevronUp, ChevronDown, Download, RefreshCw, 
  MessageSquarePlus, Info, Scissors, Maximize2, Video, 
  Eraser, Sliders, Edit3, Square, MousePointer2, LassoSelect, 
  Check, X, Undo2, Layers, Scan, Plus, Undo, Redo
} from 'lucide-react';
import { generateWorkflowImage } from '../services/gemini';

interface CanvasProps {
  items: CanvasItem[];
  zoom: number;
  onZoomChange: (newZoom: number) => void;
  pan: { x: number; y: number };
  onPanChange: (pan: { x: number; y: number }) => void;
  onItemUpdate: (id: string, updates: Partial<CanvasItem>) => void;
  onItemDelete: (id: string) => void;
  onItemDeleteMultiple: (ids: string[]) => void;
  onItemAdd: (item: CanvasItem) => void; 
  selectedIds: string[];
  setSelectedIds: (ids: string[]) => void;
}

type ResizeDirection = 'n' | 's' | 'e' | 'w' | 'ne' | 'nw' | 'se' | 'sw';

const Canvas: React.FC<CanvasProps> = ({ 
  items, zoom, onZoomChange, pan, onPanChange, onItemUpdate, onItemDelete, onItemDeleteMultiple, onItemAdd, selectedIds, setSelectedIds 
}) => {
  const [dragState, setDragState] = useState<{ id: string, startX: number, startY: number } | null>(null);
  const [resizeState, setResizeState] = useState<{ 
    id: string, direction: ResizeDirection, startX: number, startY: number, 
    startW: number, startH: number, startItemX: number, startItemY: number
  } | null>(null);
  
  const [isPanning, setIsPanning] = useState(false);
  const [isSpacePressed, setIsSpacePressed] = useState(false);
  const [lastMousePos, setLastMousePos] = useState({ x: 0, y: 0 });
  
  // 框选状态
  const [selectionBox, setSelectionBox] = useState<{ startX: number, startY: number, x: number, y: number, w: number, h: number } | null>(null);

  // 图像编辑状态 (保持之前的抠图和重绘逻辑)
  const [editTool, setEditTool] = useState<'none' | 'brush' | 'eraser' | 'cutout'>('none');
  const [brushSize, setBrushSize] = useState(30);
  const maskCanvasRef = useRef<HTMLCanvasElement | null>(null);
  const [isDrawingMask, setIsDrawingMask] = useState(false);
  const [isScanning, setIsScanning] = useState(false);
  const [isCutoutMode, setIsCutoutMode] = useState(false);

  const [contextMenu, setContextMenu] = useState<{ x: number, y: number, id: string } | null>(null);

  const containerRef = useRef<HTMLDivElement>(null);

  // 获取选中的单个图片项
  const selectedItem = selectedIds.length === 1 ? items.find(i => i.id === selectedIds[0]) : null;

  // 监听键盘事件：空格和删除
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.code === 'Space' && !['INPUT', 'TEXTAREA'].includes((e.target as HTMLElement).tagName)) {
        setIsSpacePressed(true);
        if (e.target === document.body) e.preventDefault();
      }
      if ((e.key === 'Delete' || e.key === 'Backspace') && selectedIds.length > 0 && !['INPUT', 'TEXTAREA'].includes((e.target as HTMLElement).tagName)) {
        onItemDeleteMultiple(selectedIds);
      }
    };
    const handleKeyUp = (e: KeyboardEvent) => {
      if (e.code === 'Space') setIsSpacePressed(false);
    };

    window.addEventListener('keydown', handleKeyDown);
    window.addEventListener('keyup', handleKeyUp);
    return () => {
      window.removeEventListener('keydown', handleKeyDown);
      window.removeEventListener('keyup', handleKeyUp);
    };
  }, [selectedIds, onItemDeleteMultiple]);

  // 监听滚轮：Ctrl+滚轮缩放，普通滚轮平移
  useEffect(() => {
    const handleWheel = (e: WheelEvent) => {
      if (e.ctrlKey) {
        e.preventDefault();
        const delta = -e.deltaY;
        const scaleFactor = 0.001;
        const newZoom = Math.min(Math.max(0.1, zoom + delta * scaleFactor), 5);
        onZoomChange(newZoom);
      } else {
        e.preventDefault();
        // Shift+滚轮水平滚动，普通滚轮垂直滚动
        const dx = e.shiftKey ? -e.deltaY : 0;
        const dy = e.shiftKey ? 0 : -e.deltaY;
        onPanChange({ x: pan.x + dx, y: pan.y + dy });
      }
    };
    const container = containerRef.current;
    if (container) {
      container.addEventListener('wheel', handleWheel, { passive: false });
    }
    return () => container?.removeEventListener('wheel', handleWheel);
  }, [zoom, onZoomChange, pan, onPanChange]);

  const handleMouseDown = (e: React.MouseEvent) => {
    if (e.button !== 0) return; // 仅左键

    if (isSpacePressed) {
      setIsPanning(true);
      setLastMousePos({ x: e.clientX, y: e.clientY });
      return;
    }

    if (e.target === e.currentTarget) {
      // 点击背景：开始框选
      setSelectedIds([]);
      setSelectionBox({
        startX: (e.clientX - pan.x) / zoom,
        startY: (e.clientY - pan.y) / zoom,
        x: (e.clientX - pan.x) / zoom,
        y: (e.clientY - pan.y) / zoom,
        w: 0,
        h: 0
      });
      setContextMenu(null);
      setEditTool('none');
      setIsCutoutMode(false);
    }
  };

  const handleMouseMove = (e: React.MouseEvent) => {
    if (isPanning) {
      onPanChange({ x: pan.x + (e.clientX - lastMousePos.x), y: pan.y + (e.clientY - lastMousePos.y) });
      setLastMousePos({ x: e.clientX, y: e.clientY });
      return;
    }

    if (selectionBox) {
      const curX = (e.clientX - pan.x) / zoom;
      const curY = (e.clientY - pan.y) / zoom;
      setSelectionBox({
        ...selectionBox,
        x: Math.min(curX, selectionBox.startX),
        y: Math.min(curY, selectionBox.startY),
        w: Math.abs(curX - selectionBox.startX),
        h: Math.abs(curY - selectionBox.startY)
      });
      return;
    }

    if (resizeState) {
      const dx = (e.clientX - resizeState.startX) / zoom;
      const dy = (e.clientY - resizeState.startY) / zoom;
      const { direction, startW, startH, startItemX, startItemY } = resizeState;
      let { newW, newH, newX, newY } = { newW: startW, newH: startH, newX: startItemX, newY: startItemY };
      
      if (direction.includes('e')) newW = Math.max(50, startW + dx);
      if (direction.includes('s')) newH = Math.max(50, startH + dy);
      if (direction.includes('w')) { const delta = Math.min(startW - 50, dx); newW = startW - delta; newX = startItemX + delta; }
      if (direction.includes('n')) { const delta = Math.min(startH - 50, dy); newH = startH - delta; newY = startItemY + delta; }
      
      onItemUpdate(resizeState.id, { width: newW, height: newH, x: newX, y: newY });
      return;
    }

    if (dragState) {
      const dx = (e.clientX - lastMousePos.x) / zoom;
      const dy = (e.clientY - lastMousePos.y) / zoom;
      const targetItems = items.filter(i => selectedIds.includes(i.id));
      targetItems.forEach(item => {
        onItemUpdate(item.id, { x: item.x + dx, y: item.y + dy });
      });
      setLastMousePos({ x: e.clientX, y: e.clientY });
    }
  };

  const handleMouseUp = () => {
    if (selectionBox) {
      // 计算选中的项目
      const selected = items.filter(item => {
        return (
          item.x < selectionBox.x + selectionBox.w &&
          item.x + item.width > selectionBox.x &&
          item.y < selectionBox.y + selectionBox.h &&
          item.y + item.height > selectionBox.y
        );
      }).map(i => i.id);
      setSelectedIds(selected);
      setSelectionBox(null);
    }
    setIsPanning(false);
    setDragState(null);
    setResizeState(null);
  };

  const startItemDrag = (e: React.MouseEvent, id: string) => {
    if (editTool !== 'none' || resizeState || isSpacePressed) return;
    e.stopPropagation();
    
    // 如果点击的是未选中的项目，则切换选中
    if (!selectedIds.includes(id)) {
      if (e.shiftKey) {
        setSelectedIds([...selectedIds, id]);
      } else {
        setSelectedIds([id]);
      }
    }
    
    setContextMenu(null);
    setDragState({ id, startX: e.clientX, startY: e.clientY });
    setLastMousePos({ x: e.clientX, y: e.clientY });
  };

  const renderResizeHandle = (id: string, dir: ResizeDirection) => {
    const cursors: Record<ResizeDirection, string> = {
      n: 'n-resize', s: 's-resize', e: 'e-resize', w: 'w-resize',
      ne: 'ne-resize', nw: 'nw-resize', se: 'se-resize', sw: 'sw-resize'
    };
    const style: React.CSSProperties = {
      position: 'absolute',
      width: '8px',
      height: '8px',
      backgroundColor: 'white',
      border: '1.5px solid #6366f1',
      borderRadius: '50%',
      zIndex: 100,
      cursor: cursors[dir]
    };

    if (dir.includes('n')) style.top = '-4px';
    if (dir.includes('s')) style.bottom = '-4px';
    if (dir.includes('e')) style.right = '-4px';
    if (dir.includes('w')) style.left = '-4px';
    if (dir === 'n' || dir === 's') style.left = 'calc(50% - 4px)';
    if (dir === 'e' || dir === 'w') style.top = 'calc(50% - 4px)';

    return (
      <div 
        key={dir} 
        style={style} 
        onMouseDown={(e) => {
          e.stopPropagation();
          const item = items.find(i => i.id === id);
          if (item) setResizeState({ 
            id, direction: dir, startX: e.clientX, startY: e.clientY, 
            startW: item.width, startH: item.height, startItemX: item.x, startItemY: item.y 
          });
        }}
      />
    );
  };

  return (
    <div 
      ref={containerRef}
      className={`flex-1 relative overflow-hidden canvas-grid bg-[#f5f5f5] select-none ${isSpacePressed ? 'cursor-grab active:cursor-grabbing' : 'cursor-default'}`}
      onMouseDown={handleMouseDown}
      onMouseMove={handleMouseMove}
      onMouseUp={handleMouseUp}
      onMouseLeave={handleMouseUp}
    >
      {/* 框选矩形预览 */}
      {selectionBox && (
        <div
          className="absolute border border-indigo-500 bg-indigo-500/10 pointer-events-none z-[1000]"
          style={{
            left: selectionBox.x * zoom + pan.x,
            top: selectionBox.y * zoom + pan.y,
            width: selectionBox.w * zoom,
            height: selectionBox.h * zoom
          }}
        />
      )}

      {/* 画布顶部工具栏 - 选中图片时显示 */}
      {selectedItem && (
        <div className="absolute top-4 left-1/2 -translate-x-1/2 z-[1001] flex items-center gap-1 bg-white rounded-xl shadow-lg px-2 py-1.5 border border-gray-200">
          <button className="flex items-center gap-1.5 px-3 py-1.5 text-sm text-gray-700 hover:bg-gray-100 rounded-lg transition-colors">
            <Edit3 size={16} />
            <span>局部重绘</span>
          </button>
          <button className="flex items-center gap-1.5 px-3 py-1.5 text-sm text-gray-700 hover:bg-gray-100 rounded-lg transition-colors">
            <Maximize2 size={16} />
            <span>超清</span>
            <ChevronDown size={14} />
          </button>
          <button className="flex items-center gap-1.5 px-3 py-1.5 text-sm text-gray-700 hover:bg-gray-100 rounded-lg transition-colors">
            <Scissors size={16} />
            <span>抠图</span>
          </button>
          <button className="flex items-center gap-1.5 px-3 py-1.5 text-sm text-gray-700 hover:bg-gray-100 rounded-lg transition-colors">
            <Scan size={16} />
            <span>扩图</span>
          </button>
          <button className="flex items-center gap-1.5 px-3 py-1.5 text-sm text-gray-700 hover:bg-gray-100 rounded-lg transition-colors">
            <Eraser size={16} />
            <span>消除笔</span>
          </button>
          <button className="flex items-center gap-1.5 px-3 py-1.5 text-sm text-gray-700 hover:bg-gray-100 rounded-lg transition-colors">
            <Sliders size={16} />
            <span>画面微调</span>
          </button>
          <button className="flex items-center gap-1.5 px-3 py-1.5 text-sm text-gray-700 hover:bg-gray-100 rounded-lg transition-colors">
            <Type size={16} />
            <span>文字重绘</span>
          </button>
        </div>
      )}

      <div 
        className="absolute transition-transform duration-75 will-change-transform" 
        style={{ transform: `translate(${pan.x}px, ${pan.y}px) scale(${zoom})`, transformOrigin: '0 0' }}
      >
        {items.map((item) => (
          <div
            key={item.id}
            onMouseDown={(e) => startItemDrag(e, item.id)}
            onContextMenu={(e) => { e.preventDefault(); setContextMenu({ x: e.clientX, y: e.clientY, id: item.id }); }}
            className={`absolute rounded-[12px] transition-shadow duration-300 ${selectedIds.includes(item.id) ? 'ring-2 ring-indigo-500 shadow-2xl' : 'shadow-lg'}`}
            style={{ left: item.x, top: item.y, width: item.width, height: item.height, zIndex: item.zIndex || 0 }}
          >
            <div className="w-full h-full rounded-[12px] overflow-hidden bg-white shadow-inner relative checkered-bg">
              {item.status === 'loading' ? (
                <div className="w-full h-full flex items-center justify-center bg-gray-50 z-20">
                  <Loader2 className="animate-spin text-gray-300 mb-2" />
                </div>
              ) : (
                <img src={item.content} className="w-full h-full object-cover pointer-events-none" />
              )}
            </div>
            
            {/* 调整句柄：仅在选中单个且不在抠图模式时显示全方位句柄 */}
            {selectedIds.length === 1 && selectedIds[0] === item.id && !isCutoutMode && (
              <>
                {(['n', 's', 'e', 'w', 'ne', 'nw', 'se', 'sw'] as ResizeDirection[]).map(dir => renderResizeHandle(item.id, dir))}
                {/* 图片上方快捷操作栏 */}
                <div
                  className="absolute -top-12 left-1/2 -translate-x-1/2 flex items-center gap-1 bg-white rounded-lg shadow-lg px-2 py-1 border border-gray-200"
                  style={{ transform: `translateX(-50%) scale(${1/zoom})`, transformOrigin: 'bottom center' }}
                >
                  <button className="flex items-center gap-1.5 px-2 py-1 text-sm text-gray-700 hover:bg-gray-100 rounded transition-colors whitespace-nowrap">
                    <MessageSquarePlus size={16} />
                    <span>添加到对话</span>
                  </button>
                  <button className="p-1.5 text-gray-700 hover:bg-gray-100 rounded transition-colors">
                    <Download size={16} />
                  </button>
                </div>
              </>
            )}
          </div>
        ))}
      </div>
      
      {/* 右键菜单逻辑保持一致... */}
    </div>
  );
};

export default Canvas;
