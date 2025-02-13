import React from 'react';

interface BadgeProps {
  backgroundColor?: string;
  color?: string;
  padding?: string;
  borderRadius?: number;
  fontSize?: number;
  leftIcon?: React.ReactNode;
  rightIcon?: React.ReactNode;
  text: string;
  boldText?: boolean;          // Nueva prop para controlar si el texto es negrita
  uppercaseText?: boolean;     // Nueva prop para controlar si el texto está en mayúsculas
  containerStyle?: React.CSSProperties;
  contentStyle?: React.CSSProperties;
  iconStyle?: React.CSSProperties;
}

const Badgegg: React.FC<BadgeProps> = ({
  backgroundColor = 'black',
  color = '#ffffff',
  padding = '5px 10px',
  borderRadius = 10,
  fontSize = 13,
  leftIcon,
  rightIcon,
  text,
  boldText = false,              // Valor predeterminado en false para el texto en negrita
  uppercaseText = false,         // Valor predeterminado en false para el texto en mayúsculas
  containerStyle,
  contentStyle,
  iconStyle,
}) => {
  return (
    <div
      style={{
        backgroundColor,
        color,
        padding,
        borderRadius,
        fontSize,
        ...containerStyle,
      }}
    >
      <div
        style={{
          display: 'flex',
          gap: 10,
          textAlign: 'center',
          alignItems: 'center',
          justifyContent: 'center',
          ...contentStyle,
        }}
      >
        {leftIcon && <div style={{ ...iconStyle }}>{leftIcon}</div>}
        <div
          style={{
            fontWeight: boldText ? 'bold' : 'normal',
            textTransform: uppercaseText ? 'uppercase' : 'none',  // Aplica mayúsculas si uppercaseText es true
          }}
        >
          {text}
        </div>
        {rightIcon && <div style={{ ...iconStyle }}>{rightIcon}</div>}
      </div>
    </div>
  );
};

export default Badgegg;
