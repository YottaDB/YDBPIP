/*	gtmxc_types.h - GT.M, Unix Edition External Call type definitions (Digital Unix version).  */

#ifdef __osf__
#pragma pointer_size (save)
#pragma pointer_size (short)
#endif


typedef int		xc_status_t;

typedef	int		xc_long_t;

typedef	float		xc_float_t;

typedef	double		xc_double_t;

typedef	char		xc_char_t;

typedef struct
{
	int		length;
	xc_char_t	*str;
}	xc_string_t;


#ifdef __osf__
#pragma pointer_size (restore)
#endif
