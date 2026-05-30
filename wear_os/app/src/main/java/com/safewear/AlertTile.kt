package com.safewear

import androidx.wear.tiles.*
import androidx.wear.tiles.material.Button
import androidx.wear.tiles.material.ButtonColors
import androidx.wear.tiles.material.Text
import androidx.wear.tiles.material.Typography
import androidx.wear.tiles.material.layouts.PrimaryLayout
import com.google.android.horologist.tiles.SuspendingTileService

// Wear OS Tile: shows SafeWear status and one-tap SOS button on watch face
class AlertTile : SuspendingTileService() {

    override suspend fun resourcesRequest(requestParams: ResourceBuilders.ResourcesRequest) =
        ResourceBuilders.Resources.Builder().setVersion("1").build()

    override suspend fun tileRequest(requestParams: TileBuilders.TileRequest): TileBuilders.Tile {
        val sosClickable = ActionBuilders.LaunchAction.Builder()
            .setAndroidActivity(
                ActionBuilders.AndroidActivity.Builder()
                    .setPackageName(packageName)
                    .setClassName("$packageName.MainActivity")
                    .build()
            )
            .build()
            .let {
                ModifiersBuilders.Clickable.Builder().setOnClick(it).build()
            }

        val layout = LayoutElementBuilders.Box.Builder()
            .setWidth(DimensionBuilders.expand())
            .setHeight(DimensionBuilders.expand())
            .addContent(
                LayoutElementBuilders.Column.Builder()
                    .addContent(
                        LayoutElementBuilders.Text.Builder()
                            .setText("SafeWear")
                            .setFontStyle(
                                LayoutElementBuilders.FontStyle.Builder()
                                    .setSize(DimensionBuilders.sp(16f))
                                    .setColor(ArgbEvaluatorCompat.argb(0xFFFFFFFF.toInt()))
                                    .build()
                            )
                            .build()
                    )
                    .addContent(
                        LayoutElementBuilders.Spacer.Builder()
                            .setHeight(DimensionBuilders.dp(8f))
                            .build()
                    )
                    .addContent(
                        LayoutElementBuilders.Text.Builder()
                            .setText("SOS")
                            .setModifiers(
                                ModifiersBuilders.Modifiers.Builder()
                                    .setClickable(sosClickable)
                                    .setBackground(
                                        ModifiersBuilders.Background.Builder()
                                            .setColor(ArgbEvaluatorCompat.argb(0xFFE63946.toInt()))
                                            .setCorner(
                                                ModifiersBuilders.Corner.Builder()
                                                    .setRadius(DimensionBuilders.dp(32f))
                                                    .build()
                                            )
                                            .build()
                                    )
                                    .setPadding(
                                        ModifiersBuilders.Padding.Builder()
                                            .setAll(DimensionBuilders.dp(16f))
                                            .build()
                                    )
                                    .build()
                            )
                            .setFontStyle(
                                LayoutElementBuilders.FontStyle.Builder()
                                    .setSize(DimensionBuilders.sp(20f))
                                    .setColor(ArgbEvaluatorCompat.argb(0xFFFFFFFF.toInt()))
                                    .setWeight(LayoutElementBuilders.FONT_WEIGHT_BOLD)
                                    .build()
                            )
                            .build()
                    )
                    .build()
            )
            .build()

        return TileBuilders.Tile.Builder()
            .setResourcesVersion("1")
            .setTileTimeline(
                TimelineBuilders.Timeline.fromLayoutElement(layout)
            )
            .build()
    }
}

// Minimal color helper since we cannot import compose here
object ArgbEvaluatorCompat {
    fun argb(color: Int): ColorBuilders.ColorProp =
        ColorBuilders.ColorProp.Builder(color).build()
}
