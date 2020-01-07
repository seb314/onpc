/*
 * Copyright (C) 2019. Mikhail Kulesh
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU
 * General Public License as published by the Free Software Foundation, either version 3 of the License,
 * or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without
 * even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details. You should have received a copy of the GNU General
 * Public License along with this program.
 */
import 'package:flutter/material.dart';

import "../constants/Dimens.dart";
import "../constants/Strings.dart";
import "../constants/Themes.dart";
import "../widgets/CustomActivityTitle.dart";
import "Configuration.dart";

class CheckableItem
{
    final String code;
    final String text;
    bool checked;

    CheckableItem(this.code, this.text, this.checked);

    CheckableItem.fromCode(this.code, this.checked, { this.text = "" });

    static void writeToPreference(final Configuration configuration,
        final String parameter,
        final List<CheckableItem> items)
    {
        String selectedItems = "";
        for (CheckableItem d in items)
        {
            if (d != null)
            {
                if (selectedItems.toString().isNotEmpty)
                {
                    selectedItems += ";";
                }
                selectedItems += d.code + "," + (d.checked ? "true" : "false");
            }
        }
        configuration.saveTokens(parameter, selectedItems);
    }

    static List<CheckableItem> readFromPreference(final Configuration configuration,
        final String parameter,
        final List<String> defItems)
    {
        final List<CheckableItem> retValue = List<CheckableItem>();

        final String cfg = configuration.getStringDef(parameter, "");

        // Add items stored in the configuration
        if (cfg.isNotEmpty)
        {
            final List<String> items = cfg.split(";");
            if (items.isEmpty)
            {
                for (String d in defItems)
                {
                    retValue.add(CheckableItem.fromCode(d, true));
                }
            }
            else
            {
                for (String d in items)
                {
                    final List<String> item = d.split(",");
                    if (item.length == 1)
                    {
                        retValue.add(CheckableItem.fromCode(item[0], true));
                    }
                    else if (item.length == 2)
                    {
                        retValue.add(CheckableItem.fromCode(item[0], item[1].toLowerCase() == 'true'));
                    }
                }
            }
        }

        // Add missed default items
        for (String d in defItems)
        {
            bool found = false;
            for (CheckableItem p in retValue)
            {
                if (d == p.code)
                {
                    found = true;
                    break;
                }
            }
            if (!found)
            {
                retValue.add(CheckableItem.fromCode(d, true));
            }
        }

        return retValue;
    }

    static Widget buildList(BuildContext context, List<Widget> rows, String title, ReorderCallback _onReorder, final Configuration _configuration)
    {
        final ThemeData td = BaseAppTheme.getThemeData(
            _configuration.theme, _configuration.language, _configuration.textSize);

        final Widget scaffold = Scaffold(
            appBar: PreferredSize(
                preferredSize: Size.fromHeight(ActivityDimens.appBarHeight(context)), // desired height of appBar + tabBar
                child: AppBar(title: CustomActivityTitle(Strings.drawer_app_settings, title))),
            body: Scrollbar(
                child: ReorderableListView(
                    onReorder: _onReorder,
                    reverse: false,
                    scrollDirection: Axis.vertical,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    children: rows,
                )
            ),
        );

        return Theme(data: td, child: scaffold);
    }

    Widget buildListItem(ValueChanged<bool> _onChanged)
    {
        final Widget listTile = CheckboxListTile(
            key: Key(this.code),
            isThreeLine: false,
            value: this.checked ?? false,
            onChanged: _onChanged,
            title: Text(this.text),
            secondary: const Icon(Icons.drag_handle),
        );
        return listTile;
    }
}