#include <stdint.h>

struct LinkedList;
struct LinkedList
{
  void* object;
  struct LinkedList* next;
};

struct GC_State
{
  int mark_indicator;
  uint32_t allocated_hash[137];
  struct LinkedList* allocated;
  size_t residency;
  size_t threshold;
  uint64_t* top_frame;
};

struct GC_State GC;

void gc_init(void* top_frame)
{
  GC.mark_indicator = 0b100;
  GC.allocated = NULL;
  GC.residency = 0;
  GC.threshold = 4000000L; // start with first GC when more than 4MB is in use
  GC.top_frame = top_frame;
}

static inline int is_allocated(uint64_t* object)
{
  if (GC.allocated_hash[(((size_t)object >> 3) * 131) % 137]){
    struct LinkedList* list = GC.allocated;
    while (list != NULL) {
      if (object == list->object)
        return 1;
      list = list->next;
    }
  }
  return 0;
}


void sweep ()
{
  struct LinkedList* prev = NULL;
  struct LinkedList* list = GC.allocated;
  while (list != NULL) {
    uint64_t* object = list->object;
    if (((*object)&0b100) ^ GC.mark_indicator) {
      //is marked, do nothing
      prev = list;
      list = list->next;
      continue;
    } else {
      free(object);
      GC.allocated_hash[(((size_t)object >> 3) * 131) % 137]--;
      if (prev == NULL)
        GC.allocated = list->next;
      else
        prev->next = list->next;
      struct LinkedList* temp = list->next;
      free(list);
      list = temp;
    }
  }
  GC.mark_indicator = GC.mark_indicator == 0b100 ? 0 : 0b100;
}

static inline void set_mark(uint64_t* ptr)
{
  *ptr = (*ptr & ~0b100) | GC.mark_indicator;
}

void mark(uint64_t* object)
{
  set_mark(object);
  if (*object & 1) {
    //pointer array
    uint64_t size = (*object)>>4; //TODO: check. Might not be correct
    for (uint64_t i=0; i<size; i++)
      mark(object + i*8 + 8);
  }
  else if (*object & 2) {
    //object
    uint64_t* proto = (uint64_t*)(*object&~0xF);
    uint64_t size = *proto;
    for (uint64_t i = 0; i<(size+63)>>6; i+=8) {
      uint64_t bitmap = *(proto + i*8);
      for (int j = 0; j + i*64 < size; i++) {
        if (bitmap & (1<<j))
          mark((uint64_t*)*(object + 8*(1 + i*64 + j)));
      }
    }
  }
}

void gc_collect(uint64_t* registers)
{
  uint64_t* frame = GC.top_frame;
  //mark current registers
  for (int i=0; i<6; i++)
    if (is_allocated((uint64_t*)registers[-i]))
      mark((uint64_t*)registers[-i]);
  
  while (frame != NULL) {
    //mark all saved registers
    for (int i=0; i<4; i++)
      if (is_allocated((uint64_t*)*(frame - 24 - i*8)))
        mark((uint64_t*)*(frame - 24 - i*8));
    //locals
    uint64_t* frame_descriptor = (uint64_t*)*frame;
    uint64_t size = *frame_descriptor;
    for (uint64_t i = 0; i<(size+63)>>6; i+=8) {
      uint64_t bitmap = *(frame_descriptor + i*8);
      for (int j = 0; j + i*64 < size; i++) {
        if (bitmap & (1<<j))
          mark((uint64_t*)*(frame + 8*(1 + i*64 + j)));
      }
    }
    frame = (uint64_t*)*(frame - 8);
  }
  //now sweep
  sweep();
}

void* gc_alloc(size_t size, uint64_t* registers)
{
  if (GC.residency + size > GC.threshold)
    gc_collect(registers);

  void* space = malloc(size);

  if (space == NULL) return NULL; // well, we tried our best
  
  struct LinkedList* oldhead = GC.allocated;
  GC.allocated = (struct LinkedList*)malloc(sizeof(struct LinkedList));
  GC.allocated->next = oldhead;
  GC.allocated->object = space;

  return space;
}

void* gc_update_frame(size_t* new_top)
{
  GC.top_frame = new_top;
}
