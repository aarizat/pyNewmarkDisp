use pyo3::prelude::*;
use numpy::{PyArray1, IntoPyArray};


#[inline(always)]
fn trapz(y: &[f64], x: &[f64]) -> f64 {
    0.5 * (x[1] - x[0]) * (y[1] + y[0])
}


#[pyfunction]
fn first_newmark_integration(_py: Python, time: &PyArray1<f64>, accel: &PyArray1<f64>, ay: f64) -> PyResult<Py<PyArray1<f64>>> {
    let time = unsafe {
        time.as_slice().unwrap()
    };
    let accel = unsafe {
        accel.as_slice().unwrap()
    };
    let length = time.len();
    let mut vel = vec![0.0; length];

    for i in 1..length {
        if accel[i] > ay {
            vel[i] = vel[i-1] + trapz(&[accel[i-1] - ay, accel[i]- ay], &time[i-1..=i]);
        } else if accel[i] < ay && vel[i-1] > 0.0 {
            vel[i] = vel[i-1] - trapz(&accel[i-1..=i], &time[i-1..=i]).abs();
        }
        vel[i] = vel[i].max(0.0);
    }

    Ok(vel.into_pyarray(_py).to_owned())
}


#[pyfunction]
fn cumul_integral(_py: Python, y: &PyArray1<f64>, x: &PyArray1<f64>) -> PyResult<Py<PyArray1<f64>>> {
    let y = unsafe {
        y.as_slice().unwrap()
    };
    let x = unsafe {
        x.as_slice().unwrap()
    };
    let mut cum_area = vec![0.0; x.len()];

    for i in 0..x.len() - 1 {
        let trap_area = (x[i + 1] - x[i]) * (y[i + 1] + y[i]) / 2.0;
        cum_area[i + 1] = cum_area[i] + trap_area;
    }

    Ok(cum_area.into_pyarray(_py).to_owned())
}


#[pymodule]
fn newmark_rs(_py: Python, m: &PyModule) -> PyResult<()> {
    m.add_function(wrap_pyfunction!(first_newmark_integration, m)?)?;
    m.add_function(wrap_pyfunction!(cumul_integral, m)?)?;
    Ok(())
}
