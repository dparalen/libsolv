// bitmap.i
// SWIG interface to the libsolv bitmap object

%module bitmap
%{
  #include "bitmap.h"
  #define INDEX_CHECK(map, index) \
    ({do if (index < 0 || index >= map->size << 3) return SWIG_IndexError; while(0);})
  #define ABS_INDEX(map, index)((index < 0)? (map->size << 3) + index: index)

  const int _Map_size_get(struct _Map* map) {
    return map->size << 3;
  }

%}

%feature("python:slot", "mp_subscript", functype="binaryfunc") Map::__getitem__;

%typemap(check) int size {
  if($1 < 0) {
    SWIG_exception_fail(SWIG_ValueError, "Expected a positive value or 0.");
  }
}

%typemap(ret) int {
  if ($1 == SWIG_IndexError) \
    SWIG_exception_fail(SWIG_IndexError, "Index outside range of this bitmap.");
}

typedef struct _Map {
  unsigned char *map;
  %extend {
    const int size;
    _Map(int size=0) {
      // a custom constructor that allows size to be specified
      struct _Map *ret = (struct _Map *)malloc(sizeof(struct _Map));
      map_init(ret, size);
      return ret;
    }
    ~_Map(void) {
      map_free($self);
      free($self);
    }

    int __setitem__(int index, int value) {
      int abs_index = ABS_INDEX($self, index);
      INDEX_CHECK($self, abs_index);
      if (value) map_set($self, abs_index);
      else map_clr($self, abs_index);
      return 0;
    }

    int __getitem__(int index) {
      int abs_index = ABS_INDEX($self, index);
      INDEX_CHECK($self, abs_index);
      return map_tst($self, abs_index)? 1: 0;
    }

    void grow(int size) {
      map_grow($self, size);
    }
  }
} Map;


