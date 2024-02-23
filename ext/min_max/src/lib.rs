use magnus::scan_args::scan_args;
use magnus::value::ReprValue;
use magnus::{
    block::{block_given, Yield},
    define_class, function, method,
    prelude::*,
    Error, IntoValue, RArray, Ruby, Value,
};
use magnus::{DataTypeFunctions, Integer, TypedData};
use min_max_heap::MinMaxHeap;
use std::cell::RefCell;
use std::rc::Rc;

#[derive(Debug, Clone)]
struct PriorityOrderableValue(i64, i64);

impl PartialOrd for PriorityOrderableValue {
    fn partial_cmp(&self, other: &Self) -> Option<std::cmp::Ordering> {
        Some(self.cmp(other))
    }
}

impl Ord for PriorityOrderableValue {
    fn cmp(&self, other: &Self) -> std::cmp::Ordering {
        let (PriorityOrderableValue(p1, _), PriorityOrderableValue(p2, _)) = (self, other);
        p1.cmp(p2)
    }
}

impl Eq for PriorityOrderableValue {}

impl PartialEq for PriorityOrderableValue {
    fn eq(&self, other: &Self) -> bool {
        let (PriorityOrderableValue(p1, v1), PriorityOrderableValue(p2, v2)) = (self, other);
        p1.eq(p2) && (v1).eq(v2)
    }
}

unsafe impl Send for RubyMinMaxHeap {}
#[derive(DataTypeFunctions, TypedData, Clone)]
#[magnus(class = "MinMax", size, free_immediately, mark)]
struct RubyMinMaxHeap {
    heap: Rc<RefCell<MinMaxHeap<PriorityOrderableValue>>>,
}

impl RubyMinMaxHeap {
    fn new() -> Result<Self, Error> {
        Ok(RubyMinMaxHeap {
            heap: Rc::new(RefCell::new(MinMaxHeap::new())),
        })
    }

    fn push(&self, values: RArray) -> Result<(), Error> {
        let mut hp = self.heap.borrow_mut();
        let values_vec = values.to_vec::<(i64, i64)>()?;
        values_vec.iter().for_each(|(priority, key)| {
            hp.push(PriorityOrderableValue(*priority, *key));
        });
        Ok(())
    }

    fn peek_max(&self) -> Result<Option<i64>, Error> {
        let hp = self.heap.borrow();
        match hp.peek_max() {
            Some(PriorityOrderableValue(_, value)) => Ok(Some(*value)),
            _ => Ok(None),
        }
    }

    fn peek_min(&self) -> Result<Option<i64>, Error> {
        let hp = self.heap.borrow();
        match hp.peek_min() {
            Some(PriorityOrderableValue(_, value)) => Ok(Some(*value)),
            _ => Ok(None),
        }
    }

    fn pop_max(&self, args: &[Value]) -> Result<Option<Value>, Error> {
        let args = scan_args::<(), (Option<i32>,), (), (), (), ()>(args)?;
        let (count,): (Option<i32>,) = args.optional;

        if let Some(c) = count {
            let mut result = vec![];
            for _ in 0..c {
                match { self.heap.borrow_mut() }.pop_max() {
                    Some(PriorityOrderableValue(_, value)) => result.push(Integer::from_i64(value)),
                    _ => break,
                }
            }
            let ary = RArray::new();
            ary.cat(&result)?;
            Ok(Some(ary.as_value()))
        } else {
            let mut hp = self.heap.borrow_mut();
            let val = hp.pop_max();
            match val {
                Some(PriorityOrderableValue(_, value)) => {
                    Ok(Some(Integer::from_i64(value).as_value()))
                }
                _ => Ok(None),
            }
        }
    }

    fn pop_min(&self, args: &[Value]) -> Result<Option<Value>, Error> {
        let args = scan_args::<(), (Option<i32>,), (), (), (), ()>(args)?;
        let (count,): (Option<i32>,) = args.optional;

        if let Some(c) = count {
            let mut result = vec![];
            for _ in 0..c {
                match { self.heap.borrow_mut() }.pop_min() {
                    Some(PriorityOrderableValue(_, value)) => result.push(Integer::from_i64(value)),
                    _ => break,
                }
            }
            let ary = RArray::new();
            ary.cat(&result)?;
            Ok(Some(ary.as_value()))
        } else {
            let mut hp = self.heap.borrow_mut();
            let val = hp.pop_min();
            match val {
                Some(PriorityOrderableValue(_, value)) => {
                    Ok(Some(Integer::from_i64(value).as_value()))
                }
                _ => Ok(None),
            }
        }
    }

    fn is_empty(&self) -> bool {
        self.heap.borrow().is_empty()
    }

    fn size(&self) -> usize {
        self.heap.borrow().len()
    }

    fn each(&self) -> Yield<Box<dyn Iterator<Item = Value>>> {
        if block_given() {
            let iter = self
                .heap
                .borrow()
                .clone()
                .into_vec()
                .into_iter()
                .map(|orderable_value| match orderable_value {
                    PriorityOrderableValue(_, value) => Integer::from_i64(value).as_value(),
                });
            Yield::Iter(Box::new(iter))
        } else {
            Yield::Enumerator(self.clone().into_value().enumeratorize("_each", ()))
        }
    }

    fn to_a_asc(&self) -> Result<RArray, Error> {
        let ary = RArray::new();

        let sorted: Vec<Value> = self
            .heap
            .borrow()
            .clone()
            .into_vec_asc()
            .iter()
            .map(|orderable_value| match orderable_value {
                PriorityOrderableValue(_, value) => Integer::from_i64(*value).as_value(),
            })
            .collect();
        ary.cat(&sorted)?;
        Ok(ary)
    }

    fn to_a_desc(&self) -> Result<RArray, Error> {
        let ary = RArray::new();

        let sorted: Vec<Value> = self
            .heap
            .borrow()
            .clone()
            .into_vec_desc()
            .iter()
            .map(|orderable_value| match orderable_value {
                PriorityOrderableValue(_, value) => Integer::from_i64(*value).as_value(),
            })
            .collect();
        ary.cat(&sorted)?;
        Ok(ary)
    }

    fn clear(&self) {
        self.heap.borrow_mut().clear()
    }
}

#[magnus::init]
fn init(ruby: &Ruby) -> Result<(), Error> {
    let rb_c_min_max = define_class("MinMax", ruby.class_object())?;
    rb_c_min_max.define_singleton_method("_new", function!(RubyMinMaxHeap::new, 0))?;
    rb_c_min_max.define_method("_push", method!(RubyMinMaxHeap::push, 1))?;
    rb_c_min_max.define_method("_pop_max", method!(RubyMinMaxHeap::pop_max, -1))?;
    rb_c_min_max.define_method("_pop_min", method!(RubyMinMaxHeap::pop_min, -1))?;
    rb_c_min_max.define_method("empty?", method!(RubyMinMaxHeap::is_empty, 0))?;
    rb_c_min_max.define_method("_each", method!(RubyMinMaxHeap::each, 0))?;
    rb_c_min_max.define_method("_peek_min", method!(RubyMinMaxHeap::peek_min, 0))?;
    rb_c_min_max.define_method("_peek_max", method!(RubyMinMaxHeap::peek_max, 0))?;
    rb_c_min_max.define_method("_to_a_asc", method!(RubyMinMaxHeap::to_a_asc, 0))?;
    rb_c_min_max.define_method("_to_a_desc", method!(RubyMinMaxHeap::to_a_desc, 0))?;
    rb_c_min_max.define_method("clear", method!(RubyMinMaxHeap::clear, 0))?;
    rb_c_min_max.define_method("size", method!(RubyMinMaxHeap::size, 0))?;
    rb_c_min_max.define_method("length", method!(RubyMinMaxHeap::size, 0))?;
    Ok(())
}
