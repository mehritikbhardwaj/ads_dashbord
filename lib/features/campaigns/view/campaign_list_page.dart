import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../../../widgets/dashboard_ui.dart';
import '../bloc/campaign_list_cubit.dart';
import '../widgets/campaign_card.dart';

class CampaignListPage extends StatelessWidget {
  const CampaignListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campaign List'),
        leading: IconButton(icon: const Icon(Icons.menu), onPressed: () {}),
      ),
      body: BlocBuilder<CampaignListCubit, CampaignListState>(
        builder: (context, state) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeOutCubic,
            transitionBuilder: (child, animation) =>
                FadeTransition(opacity: animation, child: child),
            child: _phaseChild(context, state),
          );
        },
      ),
    );
  }

  Widget _phaseChild(BuildContext context, CampaignListState state) {
    if (state.isLoading && state.campaigns.isEmpty) {
      return const Center(
        key: ValueKey('loading'),
        child: CircularProgressIndicator(),
      );
    }
    if (state.errorMessage != null && state.campaigns.isEmpty) {
      return _ErrorState(
        key: const ValueKey('error'),
        message: state.errorMessage!,
        onRetry: () => context.read<CampaignListCubit>().refresh(),
      );
    }
    return _ListBody(key: const ValueKey('list'), state: state);
  }
}

class _ListBody extends StatelessWidget {
  const _ListBody({required this.state, super.key});

  final CampaignListState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CampaignListCubit>();
    return Column(
      children: [
        StaggeredReveal(
          index: 0,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: _SearchField(
              initial: state.query,
              onChanged: cubit.setQuery,
            ),
          ),
        ),
        StaggeredReveal(
          index: 1,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: _FilterRow(
              selected: state.filter,
              onSelected: cubit.setFilter,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: RefreshIndicator(
            onRefresh: cubit.refresh,
            child: state.filtered.isEmpty
                ? _EmptyState(query: state.query)
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: state.filtered.length,
                    itemBuilder: (context, index) {
                      final c = state.filtered[index];
                      return StaggeredReveal(
                        key: ValueKey(
                          '${state.filter.name}-${state.query}-${c.id}',
                        ),
                        index: index + 2,
                        child: CampaignCard(
                          campaign: c,
                          ctrRatio: cubit.ctrFor(c),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}

class _SearchField extends StatefulWidget {
  const _SearchField({required this.initial, required this.onChanged});

  final String initial;
  final ValueChanged<String> onChanged;

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initial);
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final focused = _focusNode.hasFocus;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: focused ? AppTheme.accent : AppTheme.cardBorder,
          width: focused ? 1.4 : 1,
        ),
      ),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        onChanged: (v) {
          widget.onChanged(v);
          setState(() {});
        },
        textInputAction: TextInputAction.search,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          isDense: true,
          hintText: 'Search campaigns, objective, channel...',
          hintStyle: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 14,
          ),
          prefixIcon: AnimatedScale(
            scale: focused ? 1.1 : 1,
            duration: const Duration(milliseconds: 200),
            child: Icon(
              Icons.search,
              color: focused ? AppTheme.accent : AppTheme.textSecondary,
              size: 20,
            ),
          ),
          suffixIcon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            transitionBuilder: (child, anim) =>
                ScaleTransition(scale: anim, child: child),
            child: _controller.text.isEmpty
                ? const SizedBox.shrink(key: ValueKey('empty'))
                : IconButton(
                    key: const ValueKey('clear'),
                    icon: const Icon(
                      Icons.close,
                      size: 18,
                      color: AppTheme.textSecondary,
                    ),
                    onPressed: () {
                      _controller.clear();
                      widget.onChanged('');
                      setState(() {});
                    },
                  ),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({required this.selected, required this.onSelected});

  final CampaignFilter selected;
  final ValueChanged<CampaignFilter> onSelected;

  static const _items = <(CampaignFilter, String, Color?)>[
    (CampaignFilter.all, 'All', null),
    (CampaignFilter.active, 'Active', AppTheme.success),
    (CampaignFilter.paused, 'Paused', AppTheme.warning),
    (CampaignFilter.ended, 'Ended', AppTheme.textSecondary),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.zero,
      child: Row(
        children: [
          for (final item in _items) ...[
            _FilterPill(
              label: item.$2,
              selected: selected == item.$1,
              dotColor: item.$3,
              onTap: () => onSelected(item.$1),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.selected,
    required this.dotColor,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color? dotColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? AppTheme.accent : AppTheme.textSecondary;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.accent.withValues(alpha: 0.14)
              : AppTheme.card,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? AppTheme.accent : AppTheme.cardBorder,
            width: selected ? 1.2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (dotColor != null) ...[
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
            ],
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 220),
              style: TextStyle(
                color: fg,
                fontSize: 13,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    final message = query.trim().isEmpty
        ? 'No campaigns match this filter.'
        : 'No campaigns match "$query".';
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 80),
        const Icon(Icons.search_off, size: 40, color: AppTheme.textSecondary),
        const SizedBox(height: 12),
        Center(
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.textSecondary),
          ),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
    required this.onRetry,
    super.key,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppTheme.danger, size: 40),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 16),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
