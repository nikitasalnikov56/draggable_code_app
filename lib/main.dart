import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Dock(
            items: const [
              Icons.person,
              Icons.message,
              Icons.call,
              Icons.camera,
              Icons.photo,
            ],

            /// Параметр, определяющий размеры и задний фон для установленной иконки [e].
            builder: (e) {
              return Container(
                constraints: const BoxConstraints(minWidth: 48),
                height: 48,
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.primaries[e.hashCode % Colors.primaries.length],
                ),
                child: Center(child: Icon(e, color: Colors.white)),
              );
            },
          ),
        ),
      ),
    );
  }
}

class Dock<T extends Object> extends StatefulWidget {
  const Dock({
    super.key,
    this.items = const [],
    required this.builder,
    this.hoverWidth = 48,
  });

  /// Необходимые свойства для построения элементов.
  final List<T> items;
  final Widget Function(T) builder;
  final double hoverWidth;

  @override
  State<Dock<T>> createState() => _DockState<T>();
}

class _DockState<T extends Object> extends State<Dock<T>> {
  late final List<T> _items = widget.items.toList();

  /// Свойства изменения размера при наведении в параметре [childWhenDragging].
  bool _isHover = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.black12,
      ),
      height: 80,
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,

        /// Перебор всех иконок для добавления функциональности перетаскивания.
        children: _items.map((item) {
          return Draggable<T>(
            data: item,
            feedback: Material(
              color: Colors.transparent,
              child: Opacity(
                opacity: 0.7,
                child: widget.builder(item),
              ),
            ),

            /// Изменяем пространство занимаемое иконкой.
            childWhenDragging: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: _isHover ? widget.hoverWidth : 0,
              child: const SizedBox(),
            ),

            /// Обновляет состояние наведения на основе позиции перетаскивания в области стыковки
            onDragUpdate: (details) {
              _updateHoverState(details.globalPosition);
            },

            /// Сброс состояние при завершении перетаскивания.
            onDragEnd: (_) {
              setState(() {
                _isHover = false;
              });
            },
            child: DragTarget<T>(
              /// Меняет местами перетаскиваемый элемент и целевой элемент.
              onAcceptWithDetails: (details) {
                _swapItems(details.data, item);
              },
              builder: (context, candidateData, rejectedData) {
                return MouseRegion(
                  /// Отслеживание курсора в области [DragTarget].
                  onEnter: (_) {
                    setState(() {
                      _isHover = true;
                    });
                  },
                  onExit: (_) {
                    setState(() {
                      _isHover = false;
                    });
                  },
                  child: widget.builder(item),
                );
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  void _updateHoverState(Offset position) {
    final box = context.findRenderObject() as RenderBox;
    final dockPosition = box.localToGlobal(Offset.zero);
    final isWithinDockBounds =
        position.dy >= dockPosition.dy && position.dy <= dockPosition.dy + 80;

    if (isWithinDockBounds != _isHover) {
      setState(() {
        _isHover = isWithinDockBounds;
      });
    }
  }

  void _swapItems(T draggedItem, T targetItem) {
    setState(() {
      final draggedIndex = _items.indexOf(draggedItem);
      final targetIndex = _items.indexOf(targetItem);
      _items[draggedIndex] = _items[targetIndex];
      _items[targetIndex] = draggedItem;
      _isHover = false;
    });
  }
}

