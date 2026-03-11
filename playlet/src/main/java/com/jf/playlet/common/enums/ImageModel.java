package com.jf.playlet.common.enums;

/**
 * 图片生成模型枚举
 */
public enum ImageModel {
    NANO_BANANA("nano_banana", "Nano-Banana");

    private final String value;
    private final String label;

    ImageModel(String value, String label) {
        this.value = value;
        this.label = label;
    }

    public String getValue() {
        return value;
    }

    public String getLabel() {
        return label;
    }
}
